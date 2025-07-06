// import 'package:equatable/equatable.dart';
//
// abstract class NotificationEvent extends Equatable {
//   const NotificationEvent();
//
//   @override
//   List<Object?> get props => [];
// }
//
// class GetNotificationsRequested extends NotificationEvent {
//   const GetNotificationsRequested();
// }
//
// class MarkAsReadRequested extends NotificationEvent {
//   final int notificationId;
//
//   const MarkAsReadRequested({required this.notificationId});
//
//   @override
//   List<Object?> get props => [notificationId];
// }
//
// class MarkAllAsReadRequested extends NotificationEvent {
//   const MarkAllAsReadRequested();
// }
//
// class RefreshNotificationsRequested extends NotificationEvent {
//   const RefreshNotificationsRequested();
// }
import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class GetNotificationsRequested extends NotificationEvent {}

class MarkAsReadRequested extends NotificationEvent {
  final int notificationId;

  const MarkAsReadRequested({required this.notificationId});

  @override
  List<Object> get props => [notificationId];
}

class MarkAllAsReadRequested extends NotificationEvent {}
