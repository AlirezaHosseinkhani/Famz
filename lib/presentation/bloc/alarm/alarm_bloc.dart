import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/alarm/create_alarm_usecase.dart';
import '../../../domain/usecases/alarm/delete_alarm_usecase.dart';
import '../../../domain/usecases/alarm/get_alarms_usecase.dart';
import '../../../domain/usecases/alarm/toggle_alarm_usecase.dart';
import '../../../domain/usecases/alarm/update_alarm_usecase.dart';
import 'alarm_event.dart';
import 'alarm_state.dart';

class AlarmBloc extends Bloc<AlarmEvent, AlarmState> {
  final GetAlarmsUseCase getAlarmsUseCase;
  final CreateAlarmUseCase createAlarmUseCase;
  final UpdateAlarmUseCase updateAlarmUseCase;
  final DeleteAlarmUseCase deleteAlarmUseCase;
  final ToggleAlarmUseCase toggleAlarmUseCase;

  AlarmBloc({
    required this.getAlarmsUseCase,
    required this.createAlarmUseCase,
    required this.updateAlarmUseCase,
    required this.deleteAlarmUseCase,
    required this.toggleAlarmUseCase,
  }) : super(AlarmInitial()) {
    on<LoadAlarmsEvent>(_onLoadAlarms);
    on<CreateAlarmEvent>(_onCreateAlarm);
    on<UpdateAlarmEvent>(_onUpdateAlarm);
    on<DeleteAlarmEvent>(_onDeleteAlarm);
    on<ToggleAlarmEvent>(_onToggleAlarm);
    on<RefreshAlarmsEvent>(_onRefreshAlarms);
  }

  void _onLoadAlarms(LoadAlarmsEvent event, Emitter<AlarmState> emit) async {
    emit(AlarmLoading());

    final result = await getAlarmsUseCase();

    result.fold(
      (failure) => emit(AlarmError(message: failure.message)),
      (alarms) => emit(AlarmLoaded(alarms: alarms)),
    );
  }

  void _onCreateAlarm(CreateAlarmEvent event, Emitter<AlarmState> emit) async {
    emit(AlarmCreating());

    final params = CreateAlarmParams(
      time: event.time,
      isActive: event.isActive,
      recordingId: event.recordingId,
      repeatDays: event.repeatDays,
      label: event.label,
    );

    final result = await createAlarmUseCase(params);

    result.fold(
      (failure) => emit(AlarmError(message: failure.message)),
      (alarm) {
        emit(AlarmCreated(alarm: alarm));
        // Reload alarms after creation
        add(LoadAlarmsEvent());
      },
    );
  }

  void _onUpdateAlarm(UpdateAlarmEvent event, Emitter<AlarmState> emit) async {
    emit(AlarmUpdating());

    final params = UpdateAlarmParams(
      id: event.id,
      time: event.time,
      isActive: event.isActive,
      recordingId: event.recordingId,
      repeatDays: event.repeatDays,
      label: event.label,
    );

    final result = await updateAlarmUseCase(params);

    result.fold(
      (failure) => emit(AlarmError(message: failure.message)),
      (alarm) {
        emit(AlarmUpdated(alarm: alarm));
        // Reload alarms after update
        add(LoadAlarmsEvent());
      },
    );
  }

  void _onDeleteAlarm(DeleteAlarmEvent event, Emitter<AlarmState> emit) async {
    emit(AlarmDeleting());

    final result = await deleteAlarmUseCase(event.alarmId);

    result.fold(
      (failure) => emit(AlarmError(message: failure.message)),
      (success) {
        emit(AlarmDeleted(alarmId: event.alarmId));
        // Reload alarms after deletion
        add(LoadAlarmsEvent());
      },
    );
  }

  void _onToggleAlarm(ToggleAlarmEvent event, Emitter<AlarmState> emit) async {
    emit(AlarmToggling());

    final params = ToggleAlarmParams(
      id: event.alarmId,
      isActive: event.isActive,
    );

    final result = await toggleAlarmUseCase(params);

    result.fold(
      (failure) => emit(AlarmError(message: failure.message)),
      (alarm) {
        emit(AlarmToggled(alarm: alarm));
        // Reload alarms after toggle
        add(LoadAlarmsEvent());
      },
    );
  }

  void _onRefreshAlarms(
      RefreshAlarmsEvent event, Emitter<AlarmState> emit) async {
    // Don't show loading for refresh
    final result = await getAlarmsUseCase();

    result.fold(
      (failure) => emit(AlarmError(message: failure.message)),
      (alarms) => emit(AlarmLoaded(alarms: alarms)),
    );
  }
}
