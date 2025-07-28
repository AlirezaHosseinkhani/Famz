import '../../../domain/entities/record_alarm_request.dart';

class RecordAlarmRequestModel extends RecordAlarmRequest {
  const RecordAlarmRequestModel({
    required super.id,
    required super.requestId,
    required super.recordingType,
    super.audioFilePath,
    super.videoFilePath,
    super.duration,
    required super.createdAt,
    super.updatedAt,
  });

  factory RecordAlarmRequestModel.fromJson(Map<String, dynamic> json) {
    return RecordAlarmRequestModel(
      id: json['id'] as int,
      requestId: json['request'] as int,
      recordingType: json['recording_type'] as String? ?? 'audio',
      audioFilePath: json['audio_file'] as String?,
      videoFilePath: json['video_file'] as String?,
      duration: json['duration'] != null
          ? _parseDuration(json['duration'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request': requestId,
      'recording_type': recordingType,
      'audio_file': audioFilePath,
      'video_file': videoFilePath,
      'duration': duration != null ? _formatDuration(duration!) : null,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static Duration _parseDuration(String duration) {
    final parts = duration.split(':');
    if (parts.length == 3) {
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      final seconds = int.parse(parts[2]);
      return Duration(hours: hours, minutes: minutes, seconds: seconds);
    }
    return Duration.zero;
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
