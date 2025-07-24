import '../../../domain/entities/alarm.dart';

class AlarmModel extends Alarm {
  const AlarmModel({
    super.id,
    required super.scheduledTime,
    required super.videoPath,
    super.isActive = true,
    super.isRecurring = false,
    super.weekdays,
  });

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      videoPath: json['videoPath'] ?? '',
      isActive: json['isActive'] ?? true,
      isRecurring: json['isRecurring'] ?? false,
      weekdays:
          (json['weekdays'] as List?)?.cast<bool>() ?? List.filled(7, false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduledTime': scheduledTime.toIso8601String(),
      'videoPath': videoPath,
      'isActive': isActive,
      'isRecurring': isRecurring,
      'weekdays': weekdays,
    };
  }

  factory AlarmModel.fromEntity(Alarm alarm) {
    return AlarmModel(
      id: alarm.id,
      scheduledTime: alarm.scheduledTime,
      videoPath: alarm.videoPath,
      isActive: alarm.isActive,
      isRecurring: alarm.isRecurring,
      weekdays: alarm.weekdays,
    );
  }
}
