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

// import '../../../domain/usecases/alarm/create_alarm_usecase.dart';
// import '../../../domain/usecases/alarm/delete_alarm_usecase.dart';
// import '../../../domain/usecases/alarm/get_alarms_usecase.dart';
// import '../../../domain/usecases/alarm/toggle_alarm_usecase.dart';
import 'alarm_event.dart';
import 'alarm_state.dart';

class AlarmBloc extends Bloc<AlarmEvent, AlarmState> {
  final GetAlarmsUseCase getAlarmsUseCase;
  final ToggleAlarmUseCase toggleAlarmUseCase;
  final DeleteAlarmUseCase deleteAlarmUseCase;
  final CreateAlarmUseCase createAlarmUseCase;

  AlarmBloc({
    required this.getAlarmsUseCase,
    required this.toggleAlarmUseCase,
    required this.deleteAlarmUseCase,
    required this.createAlarmUseCase,
  }) : super(AlarmInitial()) {
    on<GetAlarmsRequested>(_onGetAlarmsRequested);
    on<ToggleAlarmRequested>(_onToggleAlarmRequested);
    on<DeleteAlarmRequested>(_onDeleteAlarmRequested);
    on<CreateAlarmRequested>(_onCreateAlarmRequested);
  }

  Future<void> _onGetAlarmsRequested(
    GetAlarmsRequested event,
    Emitter<AlarmState> emit,
  ) async {
    emit(AlarmLoading());

    final result = await getAlarmsUseCase();

    result.fold(
      (failure) => emit(AlarmError(message: failure.message)),
      (alarms) => emit(AlarmLoaded(alarms: alarms)),
    );
  }

  Future<void> _onToggleAlarmRequested(
    ToggleAlarmRequested event,
    Emitter<AlarmState> emit,
  ) async {
    final result = await toggleAlarmUseCase(
      ToggleAlarmParams(
        alarmId: event.alarmId,
        isActive: event.isActive,
      ),
    );

    result.fold(
      (failure) => emit(AlarmError(message: failure.message)),
      (alarm) {
        emit(AlarmToggled(alarm: alarm));
        add(GetAlarmsRequested());
      },
    );
  }

  Future<void> _onDeleteAlarmRequested(
    DeleteAlarmRequested event,
    Emitter<AlarmState> emit,
  ) async {
    final result = await deleteAlarmUseCase(
      DeleteAlarmParams(alarmId: event.alarmId),
    );

    result.fold(
      (failure) => emit(AlarmError(message: failure.message)),
      (_) {
        emit(AlarmDeleted(alarmId: event.alarmId));
        add(GetAlarmsRequested());
      },
    );
  }

  Future<void> _onCreateAlarmRequested(
    CreateAlarmRequested event,
    Emitter<AlarmState> emit,
  ) async {
    emit(AlarmLoading());

    final result = await createAlarmUseCase(
      CreateAlarmParams(
        title: event.title,
        dateTime: event.dateTime,
        audioUrl: event.audioUrl,
        videoUrl: event.videoUrl,
        description: event.description,
        isRepeating: event.isRepeating,
        repeatDays: event.repeatDays,
        ringtone: event.ringtone,
      ),
    );

    result.fold(
      (failure) => emit(AlarmError(message: failure.message)),
      (alarm) {
        emit(AlarmCreated(alarm: alarm));
        add(GetAlarmsRequested());
      },
    );
  }
}
