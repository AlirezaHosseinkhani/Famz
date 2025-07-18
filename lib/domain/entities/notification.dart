import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final int id;
  final String notificationType;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final int? alarmRequest;

  const NotificationEntity({
    required this.id,
    required this.notificationType,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.alarmRequest,
  });

  @override
  List<Object?> get props => [
        id,
        notificationType,
        message,
        isRead,
        createdAt,
        alarmRequest,
      ];
}
