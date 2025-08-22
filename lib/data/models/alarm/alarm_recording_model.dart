import '../../../domain/entities/alarm_recording.dart';

class AlarmRecordingModel extends AlarmRecording {
  const AlarmRecordingModel({
    required super.id,
    required super.requestId,
    super.audioFile,
    super.videoFile,
    required super.duration,
    required super.username,
    required super.createdAt,
    super.localPath,
    super.isDownloaded,
    super.downloadProgress,
  });

  factory AlarmRecordingModel.fromJson(Map<String, dynamic> json) {
    return AlarmRecordingModel(
      id: json['id'] as int,
      requestId: json['request'] as int,
      audioFile: json['audio_file'] as String?,
      videoFile: json['video_file'] as String?,
      duration: json['duration'] as String,
      username: json['to_user'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      localPath: json['local_path'] as String?,
      isDownloaded: json['is_downloaded'] as bool? ?? false,
      downloadProgress: (json['download_progress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request': requestId,
      'audio_file': audioFile,
      'video_file': videoFile,
      'duration': duration,
      'to_user': username,
      'created_at': createdAt.toIso8601String(),
      'local_path': localPath,
      'is_downloaded': isDownloaded,
      'download_progress': downloadProgress,
    };
  }

  factory AlarmRecordingModel.fromEntity(AlarmRecording recording) {
    return AlarmRecordingModel(
      id: recording.id,
      requestId: recording.requestId,
      audioFile: recording.audioFile,
      videoFile: recording.videoFile,
      duration: recording.duration,
      username: recording.username,
      createdAt: recording.createdAt,
      localPath: recording.localPath,
      isDownloaded: recording.isDownloaded,
      downloadProgress: recording.downloadProgress,
    );
  }
}
