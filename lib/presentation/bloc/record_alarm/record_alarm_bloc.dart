import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart' as camera;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../domain/entities/record_alarm_request.dart';
import '../../../domain/usecases/record_alarm/delete_alarm_recording_usecase.dart';
import '../../../domain/usecases/record_alarm/upload_alarm_recording_usecase.dart';
import 'record_alarm_event.dart';
import 'record_alarm_state.dart';

class RecordAlarmBloc extends Bloc<RecordAlarmEvent, RecordAlarmState> {
  final UploadAlarmRecordingUseCase uploadAlarmRecordingUseCase;
  final DeleteAlarmRecordingUseCase deleteAlarmRecordingUseCase;

  // Audio recording
  FlutterSoundRecorder? _audioRecorder;
  FlutterSoundPlayer? _audioPlayer;
  StreamSubscription? _audioPlayerSubscription;

  // Camera recording
  camera.CameraController? _cameraController;
  List<camera.CameraDescription>? _availableCameras;
  int _currentCameraIndex = 0;
  bool _camerasInitialized = false;

  // Recording state
  Timer? _recordingTimer;
  Duration _currentDuration = Duration.zero;
  String _currentRecordingPath = '';
  String _currentRecordingType = 'audio';
  bool _isRecording = false;
  bool _isPlaying = false;

  RecordAlarmBloc({
    required this.uploadAlarmRecordingUseCase,
    required this.deleteAlarmRecordingUseCase,
  }) : super(RecordAlarmInitial()) {
    on<StartRecordingEvent>(_onStartRecording);
    on<StopRecordingEvent>(_onStopRecording);
    on<PauseRecordingEvent>(_onPauseRecording);
    on<ResumeRecordingEvent>(_onResumeRecording);
    on<PlayRecordingEvent>(_onPlayRecording);
    on<StopPlaybackEvent>(_onStopPlayback);
    on<UploadRecordingEvent>(_onUploadRecording);
    on<DeleteRecordingEvent>(_onDeleteRecording);
    on<ResetRecordingEvent>(_onResetRecording);
    on<SwitchRecordingTypeEvent>(_onSwitchRecordingType);
    on<SwitchCameraEvent>(_onSwitchCamera);
    on<InitializeCameraEvent>(_onInitializeCamera);
    on<UpdateRecordingDurationEvent>(_onUpdateRecordingDuration);
    on<UpdatePlaybackPositionEvent>(_onUpdatePlaybackPosition);

    _initializeRecorders();
  }

  Future<void> _initializeRecorders() async {
    try {
      _audioRecorder = FlutterSoundRecorder();
      _audioPlayer = FlutterSoundPlayer();

      await _audioRecorder!.openRecorder();
      await _audioPlayer!.openPlayer();

      // Initialize available cameras with retry mechanism
      await _initializeCameras();
    } catch (e) {
      print('Error initializing recorders: $e');
    }
  }

  Future<void> _initializeCameras() async {
    try {
      // Request camera permission first
      final cameraPermission = await Permission.camera.status;
      if (!cameraPermission.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          print('Camera permission not granted');
          return;
        }
      }

      _availableCameras = await camera.availableCameras();
      _camerasInitialized = true;

      print('Available cameras: ${_availableCameras?.length ?? 0}');
      if (_availableCameras != null) {
        for (int i = 0; i < _availableCameras!.length; i++) {
          print(
              'Camera $i: ${_availableCameras![i].name} - ${_availableCameras![i].lensDirection}');
        }
      }
    } catch (e) {
      print('Error initializing cameras: $e');
      _camerasInitialized = false;
      _availableCameras = null;
    }
  }

  Future<void> _onInitializeCamera(
    InitializeCameraEvent event,
    Emitter<RecordAlarmState> emit,
  ) async {
    try {
      // Ensure cameras are initialized
      if (!_camerasInitialized ||
          _availableCameras == null ||
          _availableCameras!.isEmpty) {
        await _initializeCameras();
      }

      if (_availableCameras == null || _availableCameras!.isEmpty) {
        emit(CameraInitializationFailed(
            error: 'No cameras available on this device'));
        return;
      }

      await _cameraController?.dispose();

      _currentCameraIndex =
          event.cameraIndex.clamp(0, _availableCameras!.length - 1);

      _cameraController = camera.CameraController(
        _availableCameras![_currentCameraIndex],
        camera.ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: camera.ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      emit(CameraInitialized(
        cameraIndex: _currentCameraIndex,
        recordingType: _currentRecordingType,
      ));
    } catch (e) {
      print('Camera initialization error: $e');
      emit(
          CameraInitializationFailed(error: 'Failed to initialize camera: $e'));
    }
  }

  Future<void> _onSwitchCamera(
    SwitchCameraEvent event,
    Emitter<RecordAlarmState> emit,
  ) async {
    try {
      if (!_camerasInitialized ||
          _availableCameras == null ||
          _availableCameras!.length <= 1) {
        emit(RecordAlarmError(message: 'Camera switching not available'));
        return;
      }

      if (_isRecording) {
        emit(RecordAlarmError(message: 'Cannot switch camera while recording'));
        return;
      }

      emit(RecordAlarmLoading(message: 'Switching camera...'));

      await _cameraController?.dispose();

      _currentCameraIndex = event.cameraIndex % _availableCameras!.length;
      _cameraController = camera.CameraController(
        _availableCameras![_currentCameraIndex],
        camera.ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: camera.ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      emit(CameraSwitched(
        cameraIndex: _currentCameraIndex,
        recordingType: _currentRecordingType,
      ));
    } catch (e) {
      emit(RecordAlarmError(message: 'Failed to switch camera: $e'));
    }
  }

  Future<void> _onStartRecording(
    StartRecordingEvent event,
    Emitter<RecordAlarmState> emit,
  ) async {
    try {
      emit(RecordAlarmLoading(message: 'Starting recording...'));

      // Request permissions
      if (event.recordingType == 'video') {
        final cameraPermission = await Permission.camera.request();
        final microphonePermission = await Permission.microphone.request();

        if (!cameraPermission.isGranted || !microphonePermission.isGranted) {
          emit(RecordAlarmError(
              message: 'Camera and microphone permissions are required'));
          return;
        }

        // Ensure cameras are initialized for video recording
        if (!_camerasInitialized ||
            _availableCameras == null ||
            _availableCameras!.isEmpty) {
          await _initializeCameras();
        }

        if (_availableCameras == null || _availableCameras!.isEmpty) {
          emit(
              RecordAlarmError(message: 'No cameras available on this device'));
          return;
        }
      } else {
        final microphonePermission = await Permission.microphone.request();

        if (!microphonePermission.isGranted) {
          emit(RecordAlarmError(message: 'Microphone permission is required'));
          return;
        }
      }

      _currentRecordingType = event.recordingType;
      _currentDuration = Duration.zero;
      _isRecording = true;

      // Get recording path
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      if (event.recordingType == 'video') {
        _currentRecordingPath = '${directory.path}/video_$timestamp.mp4';
        await _startVideoRecording(event.cameraIndex ?? 0);
      } else {
        _currentRecordingPath = '${directory.path}/audio_$timestamp.aac';
        await _startAudioRecording();
      }

      // Start timer
      _startTimer();

      emit(RecordingInProgress(
        recordingType: _currentRecordingType,
        duration: _currentDuration,
        cameraIndex: event.cameraIndex,
      ));
    } catch (e) {
      _isRecording = false;
      print('Recording start error: $e');
      emit(RecordAlarmError(message: 'Failed to start recording: $e'));
    }
  }

  Future<void> _startAudioRecording() async {
    try {
      await _audioRecorder!.startRecorder(
        toFile: _currentRecordingPath,
        codec: Codec.aacADTS,
      );
    } catch (e) {
      throw Exception('Audio recording failed: $e');
    }
  }

  Future<void> _startVideoRecording(int cameraIndex) async {
    try {
      // Ensure cameras are available
      if (_availableCameras == null || _availableCameras!.isEmpty) {
        throw Exception('No cameras available on this device');
      }

      // Initialize camera if not already done or if camera index changed
      if (_cameraController == null ||
          _currentCameraIndex != cameraIndex ||
          !_cameraController!.value.isInitialized) {
        await _cameraController?.dispose();

        _currentCameraIndex =
            cameraIndex.clamp(0, _availableCameras!.length - 1);

        _cameraController = camera.CameraController(
          _availableCameras![_currentCameraIndex],
          camera.ResolutionPreset.high,
          enableAudio: true,
          imageFormatGroup: camera.ImageFormatGroup.jpeg,
        );

        await _cameraController!.initialize();

        // Add a small delay to ensure camera is fully ready
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (!_cameraController!.value.isInitialized) {
        throw Exception('Camera failed to initialize');
      }

      await _cameraController!.startVideoRecording();
    } catch (e) {
      throw Exception('Video recording failed: $e');
    }
  }

  void _startTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentDuration = Duration(seconds: timer.tick);
      add(UpdateRecordingDurationEvent(duration: _currentDuration));
    });
  }

  Future<void> _onStopRecording(
    StopRecordingEvent event,
    Emitter<RecordAlarmState> emit,
  ) async {
    try {
      emit(RecordAlarmLoading(message: 'Stopping recording...'));

      _recordingTimer?.cancel();
      _isRecording = false;

      File? audioFile;
      File? videoFile;

      if (_currentRecordingType == 'video') {
        if (_cameraController != null &&
            _cameraController!.value.isRecordingVideo) {
          final videoFileResult = await _cameraController!.stopVideoRecording();
          _currentRecordingPath = videoFileResult.path;
          videoFile = File(_currentRecordingPath);
        } else {
          throw Exception('Video recording was not active');
        }
      } else {
        await _audioRecorder!.stopRecorder();
        audioFile = File(_currentRecordingPath);
      }

      emit(RecordingCompleted(
        recordingType: _currentRecordingType,
        audioFile: audioFile,
        videoFile: videoFile,
        duration: _currentDuration,
        filePath: _currentRecordingPath,
      ));
    } catch (e) {
      _isRecording = false;
      emit(RecordAlarmError(message: 'Failed to stop recording: $e'));
    }
  }

  Future<void> _onPauseRecording(
    PauseRecordingEvent event,
    Emitter<RecordAlarmState> emit,
  ) async {
    try {
      _recordingTimer?.cancel();

      if (_currentRecordingType == 'audio') {
        await _audioRecorder!.pauseRecorder();
      }
      // Note: Video recording pause is not supported by camera plugin

      emit(RecordingInProgress(
        recordingType: _currentRecordingType,
        duration: _currentDuration,
        isPaused: true,
        cameraIndex: _currentCameraIndex,
      ));
    } catch (e) {
      emit(RecordAlarmError(message: 'Failed to pause recording: $e'));
    }
  }

  Future<void> _onResumeRecording(
    ResumeRecordingEvent event,
    Emitter<RecordAlarmState> emit,
  ) async {
    try {
      if (_currentRecordingType == 'audio') {
        await _audioRecorder!.resumeRecorder();
      }

      _startTimer();

      emit(RecordingInProgress(
        recordingType: _currentRecordingType,
        duration: _currentDuration,
        isPaused: false,
        cameraIndex: _currentCameraIndex,
      ));
    } catch (e) {
      emit(RecordAlarmError(message: 'Failed to resume recording: $e'));
    }
  }

  Future<void> _onPlayRecording(
    PlayRecordingEvent event,
    Emitter<RecordAlarmState> emit,
  ) async {
    try {
      if (_currentRecordingPath.isEmpty) {
        emit(RecordAlarmError(message: 'No recording to play'));
        return;
      }

      _isPlaying = true;

      if (_currentRecordingType == 'audio') {
        await _audioPlayer!.startPlayer(
          fromURI: _currentRecordingPath,
        );

        // Listen to player position updates
        _audioPlayerSubscription = _audioPlayer!.onProgress?.listen((event) {
          add(UpdatePlaybackPositionEvent(position: event.position));
        });
      }

      emit(PlayingRecording(
        recordingType: _currentRecordingType,
        audioFile: _currentRecordingType == 'audio'
            ? File(_currentRecordingPath)
            : null,
        videoFile: _currentRecordingType == 'video'
            ? File(_currentRecordingPath)
            : null,
        currentPosition: Duration.zero,
        totalDuration: _currentDuration,
        filePath: _currentRecordingPath,
      ));
    } catch (e) {
      _isPlaying = false;
      emit(RecordAlarmError(message: 'Failed to play recording: $e'));
    }
  }

  Future<void> _onStopPlayback(
    StopPlaybackEvent event,
    Emitter<RecordAlarmState> emit,
  ) async {
    try {
      _isPlaying = false;
      await _audioPlayer!.stopPlayer();
      await _audioPlayerSubscription?.cancel();
      _audioPlayerSubscription = null;

      emit(RecordingCompleted(
        recordingType: _currentRecordingType,
        audioFile: _currentRecordingType == 'audio'
            ? File(_currentRecordingPath)
            : null,
        videoFile: _currentRecordingType == 'video'
            ? File(_currentRecordingPath)
            : null,
        duration: _currentDuration,
        filePath: _currentRecordingPath,
      ));
    } catch (e) {
      emit(RecordAlarmError(message: 'Failed to stop playback: $e'));
    }
  }

  Future<void> _onUploadRecording(
    UploadRecordingEvent event,
    Emitter<RecordAlarmState> emit,
  ) async {
    try {
      emit(UploadingRecording(progress: 0.0));

      final result = await uploadAlarmRecordingUseCase.call(
        requestId: event.requestId,
        recordingType: event.recordingType,
        audioFile: event.audioFile,
        videoFile: event.videoFile,
        duration: event.duration,
      );

      result.fold(
        (failure) => emit(RecordAlarmError(message: failure.message)),
        (recording) => emit(RecordAlarmSuccess(
          recording: recording,
          message: 'Recording uploaded successfully!',
        )),
      );
    } catch (e) {
      emit(RecordAlarmError(message: 'Failed to upload recording: $e'));
    }
  }

  Future<void> _onDeleteRecording(
    DeleteRecordingEvent event,
    Emitter<RecordAlarmState> emit,
  ) async {
    try {
      emit(RecordAlarmLoading(message: 'Deleting recording...'));

      final result = await deleteAlarmRecordingUseCase.call(event.recordingId);

      result.fold(
        (failure) => emit(RecordAlarmError(message: failure.message)),
        (_) => emit(RecordAlarmSuccess(
          recording: RecordAlarmRequest(
            id: 0,
            requestId: 0,
            recordingType: '',
            createdAt: DateTime.now(),
          ),
          message: 'Recording deleted successfully!',
        )),
      );
    } catch (e) {
      emit(RecordAlarmError(message: 'Failed to delete recording: $e'));
    }
  }

  Future<void> _onResetRecording(
    ResetRecordingEvent event,
    Emitter<RecordAlarmState> emit,
  ) async {
    try {
      // Stop any ongoing operations
      _recordingTimer?.cancel();
      await _audioPlayerSubscription?.cancel();
      _audioPlayerSubscription = null;

      if (_isRecording && _currentRecordingType == 'audio') {
        await _audioRecorder!.stopRecorder();
      }

      if (_isPlaying) {
        await _audioPlayer!.stopPlayer();
      }

      // Reset state
      _currentDuration = Duration.zero;
      _currentRecordingPath = '';
      _isRecording = false;
      _isPlaying = false;

      // Clean up camera if active but don't dispose it completely
      if (_cameraController != null &&
          _cameraController!.value.isRecordingVideo) {
        try {
          await _cameraController!.stopVideoRecording();
        } catch (e) {
          print('Error stopping video recording: $e');
        }
      }

      emit(RecordAlarmInitial());
    } catch (e) {
      emit(RecordAlarmError(message: 'Failed to reset recording: $e'));
    }
  }

  Future<void> _onSwitchRecordingType(
    SwitchRecordingTypeEvent event,
    Emitter<RecordAlarmState> emit,
  ) async {
    _currentRecordingType = event.recordingType;

    // Initialize camera if switching to video
    if (event.recordingType == 'video') {
      if (!_camerasInitialized ||
          _availableCameras == null ||
          _availableCameras!.isEmpty) {
        await _initializeCameras();
      }

      if (_availableCameras != null && _availableCameras!.isNotEmpty) {
        add(InitializeCameraEvent(cameraIndex: _currentCameraIndex));
      } else {
        emit(RecordAlarmError(
            message: 'No cameras available for video recording'));
      }
    } else {
      emit(RecordingTypeChanged(recordingType: event.recordingType));
    }
  }

  Future<void> _onUpdateRecordingDuration(
    UpdateRecordingDurationEvent event,
    Emitter<RecordAlarmState> emit,
  ) async {
    if (state is RecordingInProgress) {
      final currentState = state as RecordingInProgress;
      emit(RecordingInProgress(
        recordingType: currentState.recordingType,
        duration: event.duration,
        isPaused: currentState.isPaused,
        cameraIndex: currentState.cameraIndex,
      ));
    }
  }

  Future<void> _onUpdatePlaybackPosition(
    UpdatePlaybackPositionEvent event,
    Emitter<RecordAlarmState> emit,
  ) async {
    if (state is PlayingRecording) {
      final currentState = state as PlayingRecording;
      emit(PlayingRecording(
        recordingType: currentState.recordingType,
        audioFile: currentState.audioFile,
        videoFile: currentState.videoFile,
        currentPosition: event.position,
        totalDuration: currentState.totalDuration,
        filePath: currentState.filePath,
      ));
    }
  }

  // Getters
  camera.CameraController? get cameraController => _cameraController;
  List<camera.CameraDescription>? get availableCameras => _availableCameras;
  int get currentCameraIndex => _currentCameraIndex;
  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  bool get camerasInitialized => _camerasInitialized;

  @override
  Future<void> close() async {
    _recordingTimer?.cancel();
    await _audioPlayerSubscription?.cancel();
    await _audioRecorder?.closeRecorder();
    await _audioPlayer?.closePlayer();
    await _cameraController?.dispose();
    return super.close();
  }
}
