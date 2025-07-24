import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/alarm_repository.dart';
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
  final AlarmRepository alarmRepository;

  AlarmBloc({
    required this.getAlarmsUseCase,
    required this.createAlarmUseCase,
    required this.updateAlarmUseCase,
    required this.deleteAlarmUseCase,
    required this.toggleAlarmUseCase,
    required this.alarmRepository,
  }) : super(AlarmInitial()) {
    on<InitializeAlarmServiceEvent>(_onInitializeAlarmService);
    on<LoadAlarmsEvent>(_onLoadAlarms);
    on<RefreshAlarmsEvent>(_onRefreshAlarms);
    on<CreateAlarmEvent>(_onCreateAlarm);
    on<UpdateAlarmEvent>(_onUpdateAlarm);
    on<DeleteAlarmEvent>(_onDeleteAlarm);
    on<ToggleAlarmEvent>(_onToggleAlarm);
  }

  Future<void> _onInitializeAlarmService(
    InitializeAlarmServiceEvent event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      await alarmRepository.init();
    } catch (e) {
      emit(AlarmError(
          message: 'Failed to initialize alarm service: ${e.toString()}'));
    }
  }

  Future<void> _onLoadAlarms(
    LoadAlarmsEvent event,
    Emitter<AlarmState> emit,
  ) async {
    emit(AlarmLoading());
    try {
      final alarms = await getAlarmsUseCase();
      emit(AlarmLoaded(alarms: alarms));
    } catch (e) {
      emit(AlarmError(message: 'Failed to load alarms: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshAlarms(
    RefreshAlarmsEvent event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      final alarms = await getAlarmsUseCase();
      emit(AlarmLoaded(alarms: alarms));
    } catch (e) {
      emit(AlarmError(message: 'Failed to refresh alarms: ${e.toString()}'));
    }
  }

  Future<void> _onCreateAlarm(
    CreateAlarmEvent event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      await createAlarmUseCase(event.alarm);
      emit(AlarmCreated(alarm: event.alarm));

      // Reload alarms after creation
      final alarms = await getAlarmsUseCase();
      emit(AlarmLoaded(alarms: alarms));
    } catch (e) {
      emit(AlarmError(message: 'Failed to create alarm: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateAlarm(
    UpdateAlarmEvent event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      await updateAlarmUseCase(event.alarm);
      emit(AlarmUpdated(alarm: event.alarm));

      // Reload alarms after update
      final alarms = await getAlarmsUseCase();
      emit(AlarmLoaded(alarms: alarms));
    } catch (e) {
      emit(AlarmError(message: 'Failed to update alarm: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteAlarm(
    DeleteAlarmEvent event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      await deleteAlarmUseCase(event.alarmId);
      emit(AlarmDeleted(alarmId: event.alarmId));

      // Reload alarms after deletion
      final alarms = await getAlarmsUseCase();
      emit(AlarmLoaded(alarms: alarms));
    } catch (e) {
      emit(AlarmError(message: 'Failed to delete alarm: ${e.toString()}'));
    }
  }

  Future<void> _onToggleAlarm(
    ToggleAlarmEvent event,
    Emitter<AlarmState> emit,
  ) async {
    try {
      await toggleAlarmUseCase(event.alarmId, event.isActive);

      // Get the updated alarm list to find the toggled alarm
      final alarms = await getAlarmsUseCase();
      final toggledAlarm =
          alarms.firstWhere((alarm) => alarm.id == event.alarmId);

      emit(AlarmToggled(alarm: toggledAlarm));
      emit(AlarmLoaded(alarms: alarms));
    } catch (e) {
      emit(AlarmError(message: 'Failed to toggle alarm: ${e.toString()}'));
    }
  }
}
