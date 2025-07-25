import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../domain/entities/alarm_recording.dart';

class MediaSelectorWidget extends StatefulWidget {
  final List<AlarmRecording> recordings;
  final AlarmRecording? selectedRecording;
  final Function(AlarmRecording) onRecordingSelected;
  final Function(AlarmRecording) onDownloadRequested;

  const MediaSelectorWidget({
    super.key,
    required this.recordings,
    this.selectedRecording,
    required this.onRecordingSelected,
    required this.onDownloadRequested,
  });

  @override
  State<MediaSelectorWidget> createState() => _MediaSelectorWidgetState();
}

class _MediaSelectorWidgetState extends State<MediaSelectorWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  VideoPlayerController? _videoController;
  AlarmRecording? _currentlyPlaying;

  @override
  void dispose() {
    _audioPlayer.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _playMedia(AlarmRecording recording) async {
    if (_currentlyPlaying?.id == recording.id) {
      // Stop current playback
      await _stopPlayback();
      return;
    }

    await _stopPlayback();

    if (!recording.isDownloaded || recording.localPath == null) {
      return;
    }

    setState(() {
      _currentlyPlaying = recording;
    });

    if (recording.hasAudio && !recording.hasVideo) {
      // Play audio
      await _audioPlayer.play(DeviceFileSource(recording.localPath!));
    } else if (recording.hasVideo) {
      // Play video
      _videoController = VideoPlayerController.file(File(recording.localPath!));
      await _videoController!.initialize();
      await _videoController!.play();
      setState(() {});
    }
  }

  Future<void> _stopPlayback() async {
    await _audioPlayer.stop();
    _videoController?.dispose();
    _videoController = null;
    setState(() {
      _currentlyPlaying = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.recordings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.music_off, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No recordings available',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Content from famz section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Content from famz',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ...widget.recordings
                  .map((recording) => _buildRecordingItem(recording)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Default Ringtones section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Default Ringtones',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildDefaultRingtoneItem('Radial (Default)'),
              _buildDefaultRingtoneItem('Canopy'),
              _buildDefaultRingtoneItem('Canopy'),
              _buildDefaultRingtoneItem('Forest'),
              _buildDefaultRingtoneItem('Jungle'),
              _buildDefaultRingtoneItem('Grove'),
              _buildDefaultRingtoneItem('Jungle'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingItem(AlarmRecording recording) {
    final isSelected = widget.selectedRecording?.id == recording.id;
    final isCurrentlyPlaying = _currentlyPlaying?.id == recording.id;
    final userName =
        'Hafez'; // You might want to get this from the recording data

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (recording.isDownloaded) {
            widget.onRecordingSelected(recording);
          } else {
            widget.onDownloadRequested(recording);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                isSelected ? Colors.orange.withOpacity(0.2) : Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: Colors.orange) : null,
          ),
          child: Row(
            children: [
              // Media type icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      recording.hasVideo ? Colors.blue[900] : Colors.green[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  recording.hasVideo ? Icons.videocam : Icons.mic,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Recording info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${recording.hasVideo ? 'Video' : 'Voice'} from $userName',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recording.duration,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Download/Play button
              if (!recording.isDownloaded) ...[
                if (recording.downloadProgress > 0 &&
                    recording.downloadProgress < 1) ...[
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      value: recording.downloadProgress,
                      strokeWidth: 2,
                      color: Colors.orange,
                    ),
                  ),
                ] else ...[
                  const Icon(
                    Icons.download,
                    color: Colors.orange,
                    size: 20,
                  ),
                ],
              ] else ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.orange,
                        size: 20,
                      ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _playMedia(recording),
                      child: Icon(
                        isCurrentlyPlaying ? Icons.stop : Icons.play_arrow,
                        color: Colors.orange,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultRingtoneItem(String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          // Handle default ringtone selection
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.music_note,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
              const Icon(
                Icons.play_arrow,
                color: Colors.orange,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
