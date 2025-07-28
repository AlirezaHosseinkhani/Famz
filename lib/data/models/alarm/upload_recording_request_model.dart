import 'dart:io';

class UploadRecordingRequestModel {
  final int requestId;
  final File? audioFile;
  final File? videoFile;
  final Duration duration;
  final String recordingType;

  const UploadRecordingRequestModel({
    required this.requestId,
    this.audioFile,
    this.videoFile,
    required this.duration,
    required this.recordingType,
  });

  Map<String, dynamic> toFormData() {
    final formData = <String, dynamic>{
      'request': requestId.toString(),
      'duration': _formatDuration(duration),
      'recording_type': recordingType,
    };

    return formData;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
