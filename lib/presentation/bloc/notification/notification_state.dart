// import 'package:equatable/equatable.dart';
//
// import '../../../core/errors/failures.dart';
// import '../../../domain/entities/notification.dart';
//
// abstract class NotificationState extends Equatable {
//   const NotificationState();
//
//   @override
//   List<Object?> get props => [];
// }
//
// class NotificationInitial extends NotificationState {
//   const NotificationInitial();
// }
//
// class NotificationLoading extends NotificationState {
//   const NotificationLoading();
// }
//
// class NotificationLoaded extends NotificationState {
//   final List<NotificationEntity> notifications;
//   final List<NotificationEntity> unreadNotifications;
//   final List<NotificationEntity> readNotifications;
//   final int unreadCount;
//
//   const NotificationLoaded({
//     required this.notifications,
//     required this.unreadNotifications,
//     required this.readNotifications,
//     required this.unreadCount,
//   });
//
//   @override
//   List<Object?> get props => [
//         notifications,
//         unreadNotifications,
//         readNotifications,
//         unreadCount,
//       ];
//
//   NotificationLoaded copyWith({
//     List<NotificationEntity>? notifications,
//     List<NotificationEntity>? unreadNotifications,
//     List<NotificationEntity>? readNotifications,
//     int? unreadCount,
//   }) {
//     return NotificationLoaded(
//       notifications: notifications ?? this.notifications,
//       unreadNotifications: unreadNotifications ?? this.unreadNotifications,
//       readNotifications: readNotifications ?? this.readNotifications,
//       unreadCount: unreadCount ?? this.unreadCount,
//     );
//   }
// }
//
// class NotificationError extends NotificationState {
//   final Failure failure;
//   final String message;
//
//   const NotificationError({
//     required this.failure,
//     required this.message,
//   });
//
//   @override
//   List<Object?> get props => [failure, message];
// }
//
// class NotificationActionSuccess extends NotificationState {
//   final String message;
//   final List<NotificationEntity> notifications;
//
//   const NotificationActionSuccess({
//     required this.message,
//     required this.notifications,
//   });
//
//   @override
//   List<Object?> get props => [message, notifications];
// }
import 'package:equatable/equatable.dart';

import '../../../domain/entities/notification.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  final List<NotificationEntity> notifications;

  const NotificationsLoaded(this.notifications);

  @override
  List<Object> get props => [notifications];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object> get props => [message];
}

class NotificationMarkedAsRead extends NotificationState {
  final NotificationEntity notification;

  const NotificationMarkedAsRead(this.notification);

  @override
  List<Object> get props => [notification];
}

class AllNotificationsMarkedAsRead extends NotificationState {}
