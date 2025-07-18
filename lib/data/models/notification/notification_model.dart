import '../../../domain/entities/notification.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.notificationType,
    required super.message,
    required super.isRead,
    required super.createdAt,
    required super.alarmRequest,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      notificationType: json['notification_type'] as String,
      message: json['message'] as String,
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      alarmRequest: json['alarm_request'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notification_type': notificationType,
      'message': message,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'alarm_request': alarmRequest,
    };
  }

  NotificationModel copyWith({
    int? id,
    String? notificationType,
    String? message,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      notificationType: notificationType ?? this.notificationType,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      alarmRequest: alarmRequest ?? this.alarmRequest,
    );
  }
}
