// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../domain/usecases/alarm/get_alarms_usecase.dart';
// import '../../../domain/usecases/alarm/toggle_alarm_usecase.dart';
// import '../../../domain/usecases/alarm/delete_alarm_usecase.dart';
// import '../../../domain/usecases/alarm/create_alarm_usecase.dart';
// import 'alarm_event.dart';
// import 'alarm_state.dart';
//
// class AlarmBloc extends Bloc<AlarmEvent, AlarmState> {
//   final GetAlarmsUseCase getAlarmsUseCase;
//   final ToggleAlarmUseCase toggleAlarmUseCase;
//   final DeleteAlarmUseCase deleteAlarmUseCase;
//   final CreateAlarmUseCase createAlarmUseCase;
//
//   AlarmBloc({
//     required this.getAlarmsUseCase,
//     required this.toggleAlarmUseCase,
//     required this.deleteAlarmUseCase,
//     required this.createAlarmUseCase,
//   }) : super(AlarmInitial()) {
//     on<GetAlarmsRequested>(_onGetAlarmsRequested);
//     on<ToggleAlarmRequested>(_onToggleAlarmRequested);
//     on<DeleteAlarmRequested>(_onDeleteAlarmRequested);
//     on<CreateAlarmRequested>(_onCreateAlarmRequested);
//   }
//
//   Future<void> _onGetAlarmsRequested(
//       GetAlarmsRequested event,
//       Emitter<AlarmState> emit,
//       ) async {
//     emit(AlarmLoading());
//
//     final result = await getAlarmsUseCase();
//
//     result.fold(
//           (failure) => emit(AlarmError(message: failure.message)),
//           (alarms) => emit(AlarmLoaded(alarms: alarms)),
//     );
//   }
//
//   Future<void> _onToggleAlarmRequested(
//       ToggleAlarmRequested event,
//       Emitter<AlarmState> emit,
//       ) async {
//     final result = await toggleAlarmUseCase(
//       ToggleAlarmParams(
//         alarmId: event.alarmId,
//         isActive: event.isActive,
//       ),
//     );
//
//     result.fold(
//           (failure) => emit(AlarmError(message: failure.message)),
//           (alarm) {
//         emit(AlarmToggled(alarm: alarm));
//         add(GetAlarmsRequested());
//       },
//     );
//   }
//
//   Future<void> _onDeleteAlarmRequested(
//       DeleteAlarmRequested event,
//       Emitter<AlarmState> emit,
//       ) async {
//     final result = await deleteAlarmUseCase(
//       DeleteAlarmParams(alarmId: event.alarmId),
//     );
//
//     result.fold(
//           (failure) => emit(AlarmError(message: failure.message)),
//           (_) {
//         emit(AlarmDeleted(alarmId: event.alarmId));
//         add(GetAlarmsRequested());
//       },
//     );
//   }
//
//   Future<void> _onCreateAlarmRequested(
//       CreateAlarmRequested event,
//       Emitter<AlarmState> emit,
//       ) async {
//     emit(AlarmLoading());
//
//     final result = await createAlarmUseCase(
//       CreateAlarmParams(
//         title: event.title,
//         dateTime: event.dateTime,
//         audioUrl: event.audioUrl,
//         videoUrl: event.videoUrl,
//         description: event.description,
//         isRepeating: event.isRepeating,
//         repeatDays: event.repeatDays,
//         ringtone: event.ringtone,
//       ),
//     );
//
//     result.fold(
//           (failure) => emit(AlarmError(message: failure.message)),
//           (alarm) {
//         emit(AlarmCreated(alarm: alarm));
//         add(GetAlarmsRequested());
//       },
//     );
//   }
// }

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
    on<GetAlarmsEvent>(_onGetAlarms);
    on<CreateAlarmEvent>(_onCreateAlarm);
    on<UpdateAlarmEvent>(_onUpdateAlarm);
    on<DeleteAlarmEvent>(_onDeleteAlarm);
    on<ToggleAlarmEvent>(_onToggleAlarm);
  }

  Future<void> _onGetAlarms(
    GetAlarmsEvent event,
    Emitter<AlarmState> emit,
  ) async {
    emit(AlarmLoading());

    final result = await getAlarmsUseCase();

    result.fold(
      (failure) => emit(AlarmError(failure.message)),
      (alarms) => emit(AlarmsLoaded(alarms)),
    );
  }

  Future<void> _onCreateAlarm(
    CreateAlarmEvent event,
    Emitter<AlarmState> emit,
  ) async {
    emit(AlarmLoading());

    final params = CreateAlarmParams(
      time: event.time,
      isActive: event.isActive,
      recordingId: event.recordingId,
      repeatDays: event.repeatDays,
      label: event.label,
    );

    final result = await createAlarmUseCase(params);

    result.fold(
      (failure) => emit(AlarmError(failure.message)),
      (alarm) => emit(AlarmCreated(alarm)),
    );
  }

  Future<void> _onUpdateAlarm(
    UpdateAlarmEvent event,
    Emitter<AlarmState> emit,
  ) async {
    emit(AlarmLoading());

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
      (failure) => emit(AlarmError(failure.message)),
      (alarm) => emit(AlarmUpdated(alarm)),
    );
  }

  Future<void> _onDeleteAlarm(
    DeleteAlarmEvent event,
    Emitter<AlarmState> emit,
  ) async {
    emit(AlarmLoading());

    final result = await deleteAlarmUseCase(event.alarmId);

    result.fold(
      (failure) => emit(AlarmError(failure.message)),
      (_) => emit(AlarmDeleted()),
    );
  }

  Future<void> _onToggleAlarm(
    ToggleAlarmEvent event,
    Emitter<AlarmState> emit,
  ) async {
    final params = ToggleAlarmParams(
      id: event.id,
      isActive: event.isActive,
    );

    final result = await toggleAlarmUseCase(params);

    result.fold(
      (failure) => emit(AlarmError(failure.message)),
      (alarm) => emit(AlarmToggled(alarm)),
    );
  }
}
