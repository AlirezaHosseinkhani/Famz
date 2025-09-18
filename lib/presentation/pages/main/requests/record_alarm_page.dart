import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/utils/snackbar_utils.dart';
import '../../../../domain/entities/received_request.dart';
import '../../../../injection_container.dart' as di;
import '../../../bloc/record_alarm/record_alarm_bloc.dart';
import '../../../bloc/record_alarm/record_alarm_event.dart';
import '../../../bloc/record_alarm/record_alarm_state.dart';
import '../../../widgets/common/custom_snackbar.dart';

class RecordAlarmPage extends StatefulWidget {
  final ReceivedRequest request;

  const RecordAlarmPage({
    super.key,
    required this.request,
  });

  @override
  State<RecordAlarmPage> createState() => _RecordAlarmPageState();
}

class _RecordAlarmPageState extends State<RecordAlarmPage>
    with TickerProviderStateMixin {
  late RecordAlarmBloc _recordAlarmBloc;
  String _selectedRecordingType = 'audio';
  bool _showPreview = false;

  // Camera related
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;

  // Timer related - Made these more explicit
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  bool _isTimerActive = false;

  // Video player related
  VideoPlayerController? _videoPlayerController;

  // Animation controller for recording indicator
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _recordAlarmBloc = di.sl<RecordAlarmBloc>();
    _initializeCameras();
    _setupAnimations();
    _checkPermissions();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _checkPermissions() async {
    // Check and request permissions with default notification
    final microphoneStatus = await Permission.microphone.status;
    final cameraStatus = await Permission.camera.status;

    if (!microphoneStatus.isGranted || !cameraStatus.isGranted) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Permission Required',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'This app needs access to your camera and microphone to record videos and audio.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await [Permission.microphone, Permission.camera].request();
            },
            child: const Text('Allow', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        setState(() {});
      }
    } catch (e) {
      print('Error initializing cameras: $e');
    }
  }

  void _startRecordingTimer() {
    _stopRecordingTimer();
    _recordingDuration = Duration.zero;
    _isTimerActive = true;

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isTimerActive || !mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _recordingDuration = Duration(seconds: timer.tick);
      });

      // Auto-stop at 30 seconds with duration
      if (_recordingDuration.inSeconds >= 30) {
        _recordAlarmBloc
            .add(StopRecordingEvent(recordingDuration: _recordingDuration));
      }
    });
  }

  void _stopRecordingTimer() {
    _isTimerActive = false;
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  void _resetTimer() {
    _stopRecordingTimer();
    setState(() {
      _recordingDuration = Duration.zero;
    });
  }

  // Method to handle recording type switching
  void _onRecordingTypeChanged(String newType) {
    if (_selectedRecordingType != newType) {
      // Stop any ongoing recording and timer
      if (_isTimerActive) {
        _recordAlarmBloc.add(StopRecordingEvent());
      }
      _resetTimer();

      // Stop animations
      _pulseController.stop();
      _pulseController.reset();

      setState(() {
        _selectedRecordingType = newType;
      });

      _recordAlarmBloc.add(SwitchRecordingTypeEvent(recordingType: newType));
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length <= 1) return;

    setState(() {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    });

    _recordAlarmBloc.add(SwitchCameraEvent(
      cameraIndex: _selectedCameraIndex,
    ));
  }

  Future<void> _initializeVideoPlayer(String videoPath) async {
    try {
      _videoPlayerController?.dispose();
      _videoPlayerController = VideoPlayerController.file(File(videoPath));
      await _videoPlayerController!.initialize();
      setState(() {});
    } catch (e) {
      print('Error initializing video player: $e');
    }
  }

  @override
  void dispose() {
    _stopRecordingTimer();
    _animationController.dispose();
    _pulseController.dispose();
    _videoPlayerController?.dispose();
    _recordAlarmBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _recordAlarmBloc,
      child: BlocListener<RecordAlarmBloc, RecordAlarmState>(
        listener: (context, state) {
          if (state is RecordingInProgress) {
            if (!state.isPaused) {
              _startRecordingTimer();
              _pulseController.repeat(reverse: true);
            } else {
              _stopRecordingTimer();
              _pulseController.stop();
            }
          } else if (state is RecordingCompleted) {
            _stopRecordingTimer();
            _pulseController.stop();

            if (state.videoFile != null) {
              _initializeVideoPlayer(state.videoFile!.path);
            }
          } else if (state is RecordAlarmInitial || state is RecordingReset) {
            // Handle reset state
            _resetTimer();
            _pulseController.stop();
            _pulseController.reset();
          } else if (state is RecordAlarmSuccess) {
            SnackbarUtils.showOverlaySnackbar(
              context,
              state.message,
              SnackbarType.success,
            );
            Navigator.pop(context, true);
          } else if (state is RecordAlarmError) {
            SnackbarUtils.showOverlaySnackbar(
              context,
              state.message,
              SnackbarType.error,
            );
            // Stop timer on error
            _resetTimer();
            _pulseController.stop();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                // Clean up before leaving
                _stopRecordingTimer();
                Navigator.pop(context);
              },
            ),
            title: Text(
              "Record an alarm for ${widget.request.fromUser.username ?? 'Unknown User'}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            // Text(
            //   '${widget.request.fromUser.username ?? 'Unknown User'} wants to wake up to your voice or smile 😊 🎬',
            //   style: const TextStyle(
            //     color: Colors.white,
            //     fontSize: 16,
            //     fontWeight: FontWeight.w500,
            //   ),
            // ),
            centerTitle: false,
          ),
          body: BlocBuilder<RecordAlarmBloc, RecordAlarmState>(
            builder: (context, state) {
              return Column(
                children: [
                  // Request message
                  _buildRequestMessage(),

                  // Recording type selector
                  _buildRecordingTypeSelector(state),

                  // Main recording area
                  Expanded(
                    child: _buildRecordingArea(state),
                  ),

                  // Bottom controls
                  _buildBottomControls(state),

                  const SizedBox(height: 32),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRequestMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "${widget.request.fromUser.username ?? 'Unknown User'} wants to wake up to your voice or smile 😊 🎬 and said: ${widget.request.message}",
        maxLines: 4,
        // widget.request.message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _buildRecordingTypeSelector(RecordAlarmState state) {
    // Don't show selector during recording
    if (state is RecordingInProgress) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeButton(
              'Record a Video',
              Icons.videocam,
              'video',
              _selectedRecordingType == 'video',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTypeButton(
              'Record a Voice',
              Icons.mic,
              'audio',
              _selectedRecordingType == 'audio',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(
      String title, IconData icon, String type, bool isSelected) {
    return GestureDetector(
      onTap: () => _onRecordingTypeChanged(type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF3B30) : const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFF38383A), width: 1),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingArea(RecordAlarmState state) {
    if (_selectedRecordingType == 'video') {
      return _buildVideoRecordingArea(state);
    } else {
      return _buildAudioRecordingArea(state);
    }
  }

  Widget _buildVideoRecordingArea(RecordAlarmState state) {
    // Show video preview during playback
    if (state is PlayingRecording && _videoPlayerController != null) {
      return Container(
        margin: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: VideoPlayer(_videoPlayerController!),
          ),
        ),
      );
    }

    // Show camera preview during recording or when initialized
    if (state is RecordingInProgress ||
        state is RecordingCompleted ||
        (state is RecordAlarmBloc &&
            _recordAlarmBloc.cameraController != null)) {
      final cameraController = _recordAlarmBloc.cameraController;

      if (cameraController != null && cameraController.value.isInitialized) {
        return Stack(
          children: [
            Container(
              margin: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: OverflowBox(
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.fitHeight,
                      child: SizedBox(
                        width: cameraController.value.previewSize!.height,
                        height: cameraController.value.previewSize!.width,
                        child: CameraPreview(cameraController),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Camera switch button
            if (_cameras != null && _cameras!.length > 1)
              Positioned(
                top: 40,
                right: 40,
                child: GestureDetector(
                  onTap: _switchCamera,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.flip_camera_ios,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            // Recording timer overlay
            if (state is RecordingInProgress && _isTimerActive)
              Positioned(
                top: 40,
                left: 40,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B30),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDuration(_recordingDuration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      }
    }

    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Tap record to start video recording',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioRecordingArea(RecordAlarmState state) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Large circular recording area
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white10,
              ),
              child: Center(
                child: _buildRecordingIndicator(state),
              ),
            ),
            const SizedBox(height: 40),
            // Status text
            Text(
              _getAudioStatusText(state),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (state is RecordingInProgress) ...[
              const SizedBox(height: 8),
              Text(
                '(max record time is 30 seconds)',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingIndicator(RecordAlarmState state) {
    if (state is RecordingInProgress && _isTimerActive) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF3B30),
              ),
            ),
          );
        },
      );
    } else if (state is RecordingCompleted) {
      return Container(
        width: 120,
        height: 120,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF34C759),
        ),
        child: const Icon(
          Icons.check,
          size: 60,
          color: Colors.white,
        ),
      );
    } else {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFF3B30),
        ),
        child: const Icon(
          Icons.fiber_manual_record,
          size: 40,
          color: Colors.white,
        ),
      );
    }
  }

  Widget _buildBottomControls(RecordAlarmState state) {
    if (state is RecordingInProgress) {
      return _buildRecordingControls(state);
    } else if (state is RecordingCompleted || state is PlayingRecording) {
      return _buildCompletedControls(state);
    } else if (state is RecordAlarmLoading || state is UploadingRecording) {
      return _buildLoadingControls(state);
    } else {
      return _buildInitialControls();
    }
  }

  Widget _buildInitialControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Record button for audio
          if (_selectedRecordingType == 'audio')
            Expanded(
              child: _buildStyledButton(
                icon: Icons.mic,
                text: 'Record',
                backgroundColor: const Color(0xFFFF3B30),
                onPressed: () {
                  _recordAlarmBloc.add(
                    StartRecordingEvent(
                      recordingType: _selectedRecordingType,
                      cameraIndex: _selectedCameraIndex,
                    ),
                  );
                },
              ),
            ),
          // Record button for video
          if (_selectedRecordingType == 'video') ...[
            Expanded(
              child: _buildStyledButton(
                icon: Icons.videocam,
                text: 'Record',
                backgroundColor: const Color(0xFFFF3B30),
                onPressed: () {
                  _recordAlarmBloc.add(
                    StartRecordingEvent(
                      recordingType: _selectedRecordingType,
                      cameraIndex: _selectedCameraIndex,
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecordingControls(RecordAlarmState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Timer display - only show if timer is active
          if (_isTimerActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3B30),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(_recordingDuration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '/ 0:30',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          // Stop button
          _buildStyledButton(
            icon: Icons.stop,
            text: 'Stop',
            backgroundColor: const Color(0xFF48484A),
            onPressed: () => _recordAlarmBloc
                .add(StopRecordingEvent(recordingDuration: _recordingDuration)),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedControls(RecordAlarmState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              // Delete button
              Expanded(
                child: _buildStyledButton(
                  icon: Icons.delete_outline,
                  text: 'Delete',
                  backgroundColor: const Color(0xFF48484A),
                  onPressed: () {
                    _videoPlayerController?.dispose();
                    _videoPlayerController = null;
                    _resetTimer();
                    _recordAlarmBloc.add(ResetRecordingEvent());
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Play button
              Expanded(
                child: _buildStyledButton(
                  icon: state is PlayingRecording
                      ? Icons.pause
                      : Icons.play_arrow,
                  text: state is PlayingRecording ? 'Pause' : 'Play',
                  backgroundColor: const Color(0xFF48484A),
                  onPressed: () {
                    if (state is PlayingRecording) {
                      _recordAlarmBloc.add(StopPlaybackEvent());
                      _videoPlayerController?.pause();
                    } else {
                      _recordAlarmBloc.add(PlayRecordingEvent());
                      if (_selectedRecordingType == 'video' &&
                          _videoPlayerController != null) {
                        _videoPlayerController!.play();
                      }
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Send button
              Expanded(
                child: _buildStyledButton(
                  icon: Icons.send,
                  text: 'Send',
                  backgroundColor: const Color(0xFF34C759),
                  onPressed: () {
                    final completedState = state as RecordingCompleted;
                    _recordAlarmBloc.add(UploadRecordingEvent(
                      requestId: widget.request.id,
                      recordingType: completedState.recordingType,
                      audioFile: completedState.audioFile,
                      videoFile: completedState.videoFile,
                      duration: completedState.duration,
                    ));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingControls(RecordAlarmState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: Color(0xFFFF9500),
          ),
          const SizedBox(height: 16),
          Text(
            state is UploadingRecording
                ? 'Processing Recorded Media\nPlease Wait and don\'t close this app'
                : 'Loading...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStyledButton({
    required IconData icon,
    required String text,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAudioStatusText(RecordAlarmState state) {
    if (state is RecordingInProgress && _isTimerActive) {
      return 'Recording...';
    } else if (state is RecordingCompleted) {
      return 'Recording completed';
    } else {
      return 'Click record to start recording.';
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(1, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
