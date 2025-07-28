class RecordAlarmRequest {
  final int id;
  final int requestId;
  final String recordingType; // 'audio' or 'video'
  final String? audioFilePath;
  final String? videoFilePath;
  final Duration? duration;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const RecordAlarmRequest({
    required this.id,
    required this.requestId,
    required this.recordingType,
    this.audioFilePath,
    this.videoFilePath,
    this.duration,
    required this.createdAt,
    this.updatedAt,
  });
}
