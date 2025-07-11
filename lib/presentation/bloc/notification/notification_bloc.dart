// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../domain/usecases/notification/get_notifications_usecase.dart';
// import '../../../domain/usecases/notification/mark_as_read_usecase.dart';
// import '../../../domain/usecases/notification/mark_all_as_read_usecase.dart';
// import 'notification_event.dart';
// import 'notification_state.dart';
//
// class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
//   final GetNotificationsUseCase getNotificationsUseCase;
//   final MarkAsReadUseCase markAsReadUseCase;
//   final MarkAllAsReadUseCase markAllAsReadUseCase;
//
//   NotificationBloc({
//     required this.getNotificationsUseCase,
//     required this.markAsReadUseCase,
//     required this.markAllAsReadUseCase,
//   }) : super(NotificationInitial()) {
//     on<GetNotificationsRequested>(_onGetNotificationsRequested);
//     on<MarkAsReadRequested>(_onMarkAsReadRequested);
//     on<MarkAllAsReadRequested>(_onMarkAllAsReadRequested);
//   }
//
//   Future<void> _onGetNotificationsRequested(
//       GetNotificationsRequested event,
//       Emitter<NotificationState> emit,
//       ) async {
//     emit(NotificationLoading());
//
//     final result = await getNotificationsUseCase();
//
//     result.fold(
//           (failure) => emit(NotificationError(message: failure.message)),
//           (notifications) => emit(NotificationLoaded(notifications: notifications)),
//     );
//   }
//
//   Future<void> _onMarkAsReadRequested(
//       MarkAsReadRequested event,
//       Emitter<NotificationState> emit,
//       ) async {
//     final result = await markAsReadUseCase(
//       MarkAsReadParams(notificationId: event.notificationId),
//     );
//
//     result.fold(
//           (failure) => emit(NotificationError(message: failure.message)),
//           (_) {
//         emit(NotificationMarkedAsRead(notificationId: event.notificationId));
//         add(GetNotificationsRequested());
//       },
//     );
//   }
//
//   Future<void> _onMarkAllAsReadRequested(
//       MarkAllAsReadRequested event,
//       Emitter<NotificationState> emit,
//       ) async {
//     final result = await markAllAsReadUseCase();
//
//     result.fold(
//           (failure) => emit(NotificationError(message: failure.message)),
//           (_) {
//         emit(AllNotificationsMarkedAsRead());
//         add(GetNotificationsRequested());
//       },
//     );
//   }
// }
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/notification/get_notifications_usecase.dart';
import '../../../domain/usecases/notification/mark_all_as_read_usecase.dart';
import '../../../domain/usecases/notification/mark_as_read_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkAsReadUseCase markAsReadUseCase;
  final MarkAllAsReadUseCase markAllAsReadUseCase;

  NotificationBloc({
    required this.getNotificationsUseCase,
    required this.markAsReadUseCase,
    required this.markAllAsReadUseCase,
  }) : super(NotificationInitial()) {
    on<GetNotificationsEvent>(_onGetNotifications);
    on<MarkAsReadEvent>(_onMarkAsRead);
    on<MarkAllAsReadEvent>(_onMarkAllAsRead);
  }

  Future<void> _onGetNotifications(
    GetNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());

    final result = await getNotificationsUseCase();

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (notifications) => emit(NotificationsLoaded(notifications)),
    );
  }

  Future<void> _onMarkAsRead(
    MarkAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await markAsReadUseCase(event.notificationId);

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (notification) => emit(NotificationMarkedAsRead(notification)),
    );
  }

  Future<void> _onMarkAllAsRead(
    MarkAllAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await markAllAsReadUseCase();

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) => emit(AllNotificationsMarkedAsRead()),
    );
  }
}
