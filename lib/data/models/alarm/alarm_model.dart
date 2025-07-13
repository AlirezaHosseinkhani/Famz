import '../../../domain/entities/alarm.dart';

class AlarmModel extends Alarm {
  const AlarmModel({
    super.id,
    required super.time,
    required super.isActive,
    super.recordingId,
    super.repeatDays,
    super.label,
    super.recordingTitle,
    super.recordingType,
    super.recordingUrl,
    super.createdAt,
    super.updatedAt,
  });

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'],
      time: DateTime.parse(json['time']),
      isActive: json['is_active'] ?? false,
      recordingId: json['recording_id'],
      repeatDays: json['repeat_days'] != null
          ? List<int>.from(json['repeat_days'])
          : null,
      label: json['label'],
      recordingTitle: json['recording_title'],
      recordingType: json['recording_type'],
      recordingUrl: json['recording_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time.toIso8601String(),
      'is_active': isActive,
      'recording_id': recordingId,
      'repeat_days': repeatDays,
      'label': label,
      'recording_title': recordingTitle,
      'recording_type': recordingType,
      'recording_url': recordingUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory AlarmModel.fromEntity(Alarm alarm) {
    return AlarmModel(
      id: alarm.id,
      time: alarm.time,
      isActive: alarm.isActive,
      recordingId: alarm.recordingId,
      repeatDays: alarm.repeatDays,
      label: alarm.label,
      recordingTitle: alarm.recordingTitle,
      recordingType: alarm.recordingType,
      recordingUrl: alarm.recordingUrl,
      createdAt: alarm.createdAt,
      updatedAt: alarm.updatedAt,
    );
  }

  Alarm toEntity() {
    return Alarm(
      id: id,
      time: time,
      isActive: isActive,
      recordingId: recordingId,
      repeatDays: repeatDays,
      label: label,
      recordingTitle: recordingTitle,
      recordingType: recordingType,
      recordingUrl: recordingUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
