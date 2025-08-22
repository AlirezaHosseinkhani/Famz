import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/utils/snackbar_utils.dart';
import '../../../../domain/entities/received_request.dart';
import '../../../../injection_container.dart' as di;
import '../../../bloc/record_alarm/record_alarm_bloc.dart';
import '../../../bloc/record_alarm/record_alarm_event.dart';
import '../../../bloc/record_alarm/record_alarm_state.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_snackbar.dart';
import '../../../widgets/common/loading_widget.dart';

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

  // Timer related
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;

  // Video player related
  VideoPlayerController? _videoPlayerController;

  // Animation controller for recording indicator
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _recordAlarmBloc = di.sl<RecordAlarmBloc>();
    _initializeCameras();
    _setupAnimations();
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
    _animationController.repeat(reverse: true);
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
    _recordingDuration = Duration.zero;
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration = Duration(seconds: timer.tick);
      });
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
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
              if (_selectedRecordingType == 'audio') {
                _animationController.repeat(reverse: true);
              }
            } else {
              _stopRecordingTimer();
              _animationController.stop();
            }
          } else if (state is RecordingCompleted) {
            _stopRecordingTimer();
            _animationController.stop();

            // Initialize video player if video was recorded
            if (state.videoFile != null) {
              _initializeVideoPlayer(state.videoFile!.path);
            }
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
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Record Alarm',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              // Camera switch button (only show for video recording)
              if (_selectedRecordingType == 'video' &&
                  _cameras != null &&
                  _cameras!.length > 1)
                IconButton(
                  icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                  onPressed: _switchCamera,
                ),
            ],
          ),
          body: BlocBuilder<RecordAlarmBloc, RecordAlarmState>(
            builder: (context, state) {
              return Column(
                children: [
                  // Request Info
                  _buildRequestInfo(),

                  // Recording Type Selector
                  _buildRecordingTypeSelector(),

                  // Timer Display (always visible during recording)
                  if (state is RecordingInProgress ||
                      _recordingDuration.inSeconds > 0)
                    _buildTimerDisplay(),

                  // Camera/Recording Area
                  Expanded(
                    child: _buildRecordingArea(state),
                  ),

                  // Controls
                  _buildControls(state),

                  const SizedBox(height: 32),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTimerDisplay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatDuration(_recordingDuration),
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recording for ${widget.request.fromUser.username ?? 'Unknown User'}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.request.message,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingTypeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeButton(
              'Voice',
              Icons.mic,
              'audio',
              _selectedRecordingType == 'audio',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTypeButton(
              'Video',
              Icons.videocam,
              'video',
              _selectedRecordingType == 'video',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(
      String title, IconData icon, String type, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRecordingType = type;
        });
        _recordAlarmBloc.add(SwitchRecordingTypeEvent(recordingType: type));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.grey[800],
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.grey[600]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
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
        margin: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 9 / 16, // Vertical aspect ratio for mobile
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
        return Container(
          margin: const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 9 / 16, // Vertical aspect ratio
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
        );
      }
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
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
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated recording indicator
            if (state is RecordingInProgress && !state.isPaused)
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.withOpacity(0.3),
                      ),
                      child: const Icon(
                        Icons.mic,
                        size: 40,
                        color: Colors.red,
                      ),
                    ),
                  );
                },
              )
            else
              Icon(
                Icons.mic,
                size: 80,
                color: state is RecordingCompleted ? Colors.green : Colors.grey,
              ),

            const SizedBox(height: 24),

            // Status text
            Text(
              _getStatusText(state),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(RecordAlarmState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Recording controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Record/Stop button
              _buildMainRecordButton(state),

              // Play/Pause button (only when recording is completed)
              if (state is RecordingCompleted || state is PlayingRecording)
                _buildPlayButton(state),

              // Send button (only when recording is completed)
              if (state is RecordingCompleted) _buildSendButton(state),
            ],
          ),

          const SizedBox(height: 16),

          // Reset button
          if (state is RecordingCompleted || state is PlayingRecording)
            CustomButton(
              text: 'Record Again',
              onPressed: () {
                _videoPlayerController?.dispose();
                _videoPlayerController = null;
                _recordingDuration = Duration.zero;
                _recordAlarmBloc.add(ResetRecordingEvent());
              },
              backgroundColor: Colors.grey[700],
              textColor: Colors.white,
            ),

          // Loading indicator
          if (state is RecordAlarmLoading || state is UploadingRecording)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: LoadingWidget(),
            ),
        ],
      ),
    );
  }

  Widget _buildMainRecordButton(RecordAlarmState state) {
    IconData icon;
    Color color;
    VoidCallback? onPressed;

    if (state is RecordingInProgress) {
      if (state.isPaused) {
        icon = Icons.play_arrow;
        color = Colors.green;
        onPressed = () => _recordAlarmBloc.add(ResumeRecordingEvent());
      } else {
        icon = Icons.stop;
        color = Colors.red;
        onPressed = () => _recordAlarmBloc.add(StopRecordingEvent());
      }
    } else {
      icon = Icons.fiber_manual_record;
      color = Colors.red;
      onPressed = () {
        _recordAlarmBloc.add(
          StartRecordingEvent(
            recordingType: _selectedRecordingType,
            cameraIndex: _selectedCameraIndex,
          ),
        );
      };
    }

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildPlayButton(RecordAlarmState state) {
    final isPlaying = state is PlayingRecording;

    return GestureDetector(
      onTap: () {
        if (isPlaying) {
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
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.stop : Icons.play_arrow,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildSendButton(RecordAlarmState state) {
    if (state is! RecordingCompleted) return const SizedBox();

    return GestureDetector(
      onTap: () {
        _recordAlarmBloc.add(UploadRecordingEvent(
          requestId: widget.request.id,
          recordingType: state.recordingType,
          audioFile: state.audioFile,
          videoFile: state.videoFile,
          duration: state.duration,
        ));
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green,
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(
          Icons.send,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  String _getStatusText(RecordAlarmState state) {
    if (state is RecordingInProgress) {
      return state.isPaused ? 'Recording paused' : 'Recording...';
    } else if (state is RecordingCompleted) {
      return 'Recording completed';
    } else if (state is PlayingRecording) {
      return 'Playing...';
    } else if (state is UploadingRecording) {
      return state.message;
    }
    return 'Tap record to start';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
