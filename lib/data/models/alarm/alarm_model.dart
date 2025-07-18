import '../../../domain/entities/alarm.dart';

class AlarmModel extends Alarm {
  const AlarmModel({
    super.id,
    super.request,
    super.audioFile,
    super.videoFile,
    super.duration,
    super.createdAt,
  });

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'],
      request: json['request'],
      audioFile: json['audio_file'],
      videoFile: json['video_file'],
      duration:
          json['duration'] != null ? DateTime.parse(json['duration']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request': request,
      'audio_file': audioFile,
      'video_file': videoFile,
      'duration': duration,
      'created_at': createdAt,
    };
  }
}
