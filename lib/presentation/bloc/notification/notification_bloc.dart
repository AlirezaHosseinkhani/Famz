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
    on<RefreshNotificationsEvent>(_onRefreshNotifications);
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
      (notifications) => emit(NotificationLoaded(notifications)),
    );
  }

  Future<void> _onRefreshNotifications(
    RefreshNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await getNotificationsUseCase();

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (notifications) => emit(NotificationLoaded(notifications)),
    );
  }

  Future<void> _onMarkAsRead(
    MarkAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      emit(NotificationMarkingAsRead(
          currentState.notifications, event.notificationId));

      final result = await markAsReadUseCase(event.notificationId);

      result.fold(
        (failure) => emit(NotificationError(failure.message)),
        (updatedNotification) {
          final updatedNotifications =
              currentState.notifications.map((notification) {
            if (notification.id == event.notificationId) {
              return updatedNotification;
            }
            return notification;
          }).toList();
          emit(NotificationLoaded(updatedNotifications));
        },
      );
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      emit(NotificationMarkingAllAsRead(currentState.notifications));

      final result = await markAllAsReadUseCase();

      result.fold(
        (failure) => emit(NotificationError(failure.message)),
        (_) {
          // Refresh notifications after marking all as read
          add(RefreshNotificationsEvent());
        },
      );
    }
  }
}
