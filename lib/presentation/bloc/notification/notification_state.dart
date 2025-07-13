import 'package:equatable/equatable.dart';

import '../../../domain/entities/notification.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;

  const NotificationLoaded(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationMarkingAsRead extends NotificationState {
  final List<NotificationEntity> notifications;
  final int notificationId;

  const NotificationMarkingAsRead(this.notifications, this.notificationId);

  @override
  List<Object?> get props => [notifications, notificationId];
}

class NotificationMarkingAllAsRead extends NotificationState {
  final List<NotificationEntity> notifications;

  const NotificationMarkingAllAsRead(this.notifications);

  @override
  List<Object?> get props => [notifications];
}
