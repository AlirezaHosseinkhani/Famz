// import 'package:equatable/equatable.dart';
//
// import '../../../core/errors/failures.dart';
// import '../../../domain/entities/alarm.dart';
//
// abstract class AlarmState extends Equatable {
//   const AlarmState();
//
//   @override
//   List<Object?> get props => [];
// }
//
// class AlarmInitial extends AlarmState {
//   const AlarmInitial();
// }
//
// class AlarmLoading extends AlarmState {
//   const AlarmLoading();
// }
//
// class AlarmLoaded extends AlarmState {
//   final List<Alarm> alarms;
//   final List<Alarm> activeAlarms;
//   final List<Alarm> inactiveAlarms;
//
//   const AlarmLoaded({
//     required this.alarms,
//     required this.activeAlarms,
//     required this.inactiveAlarms,
//   });
//
//   @override
//   List<Object?> get props => [alarms, activeAlarms, inactiveAlarms];
//
//   AlarmLoaded copyWith({
//     List<Alarm>? alarms,
//     List<Alarm>? activeAlarms,
//     List<Alarm>? inactiveAlarms,
//   }) {
//     return AlarmLoaded(
//       alarms: alarms ?? this.alarms,
//       activeAlarms: activeAlarms ?? this.activeAlarms,
//       inactiveAlarms: inactiveAlarms ?? this.inactiveAlarms,
//     );
//   }
// }
//
// class AlarmError extends AlarmState {
//   final Failure failure;
//   final String message;
//
//   const AlarmError({
//     required this.failure,
//     required this.message,
//   });
//
//   @override
//   List<Object?> get props => [failure, message];
// }
//
// class AlarmActionSuccess extends AlarmState {
//   final String message;
//   final List<Alarm> alarms;
//
//   const AlarmActionSuccess({
//     required this.message,
//     required this.alarms,
//   });
//
//   @override
//   List<Object?> get props => [message, alarms];
// }
import 'package:equatable/equatable.dart';

import '../../../domain/entities/alarm.dart';

abstract class AlarmState extends Equatable {
  const AlarmState();

  @override
  List<Object?> get props => [];
}

class AlarmInitial extends AlarmState {}

class AlarmLoading extends AlarmState {}

class AlarmLoaded extends AlarmState {
  final List<Alarm> alarms;

  const AlarmLoaded({required this.alarms});

  @override
  List<Object> get props => [alarms];
}

class AlarmError extends AlarmState {
  final String message;

  const AlarmError({required this.message});

  @override
  List<Object> get props => [message];
}

class AlarmToggled extends AlarmState {
  final Alarm alarm;

  const AlarmToggled({required this.alarm});

  @override
  List<Object> get props => [alarm];
}

class AlarmDeleted extends AlarmState {
  final int alarmId;

  const AlarmDeleted({required this.alarmId});

  @override
  List<Object> get props => [alarmId];
}

class AlarmCreated extends AlarmState {
  final Alarm alarm;

  const AlarmCreated({required this.alarm});

  @override
  List<Object> get props => [alarm];
}
