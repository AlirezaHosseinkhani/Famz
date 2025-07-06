import 'package:famz/domain/entities/alarm.dart';

class AlarmModel extends Alarm {
  const AlarmModel({
    required super.id,
    required super.time,
    required super.isActive,
    super.title,
    super.description,
    super.repeatDays,
    super.recordingId,
    super.recordingType,
    super.createdAt,
    super.updatedAt,
  });

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'] as int,
      time: DateTime.parse(json['time'] as String),
      isActive: json['isActive'] as bool,
      title: json['title'] as String?,
      description: json['description'] as String?,
      repeatDays: (json['repeatDays'] as List<dynamic>?)?.cast<int>(),
      recordingId: json['recordingId'] as int?,
      recordingType: json['recordingType'] != null
          ? RecordingType.values.firstWhere(
              (e) => e.toString().split('.').last == json['recordingType'],
              orElse: () => RecordingType.audio,
            )
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time.toIso8601String(),
      'isActive': isActive,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (repeatDays != null) 'repeatDays': repeatDays,
      if (recordingId != null) 'recordingId': recordingId,
      if (recordingType != null)
        'recordingType': recordingType.toString().split('.').last,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  factory AlarmModel.fromEntity(Alarm alarm) {
    return AlarmModel(
      id: alarm.id,
      time: alarm.time,
      isActive: alarm.isActive,
      title: alarm.title,
      description: alarm.description,
      repeatDays: alarm.repeatDays,
      recordingId: alarm.recordingId,
      recordingType: alarm.recordingType,
      createdAt: alarm.createdAt,
      updatedAt: alarm.updatedAt,
    );
  }
}
