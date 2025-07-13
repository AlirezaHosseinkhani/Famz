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

  List<Alarm> get activeAlarms =>
      alarms.where((alarm) => alarm.isActive).toList();

  List<Alarm> get inactiveAlarms =>
      alarms.where((alarm) => !alarm.isActive).toList();

  @override
  List<Object> get props => [alarms];
}

class AlarmError extends AlarmState {
  final String message;

  const AlarmError({required this.message});

  @override
  List<Object> get props => [message];
}

class AlarmCreating extends AlarmState {}

class AlarmCreated extends AlarmState {
  final Alarm alarm;

  const AlarmCreated({required this.alarm});

  @override
  List<Object> get props => [alarm];
}

class AlarmUpdating extends AlarmState {}

class AlarmUpdated extends AlarmState {
  final Alarm alarm;

  const AlarmUpdated({required this.alarm});

  @override
  List<Object> get props => [alarm];
}

class AlarmDeleting extends AlarmState {}

class AlarmDeleted extends AlarmState {
  final int alarmId;

  const AlarmDeleted({required this.alarmId});

  @override
  List<Object> get props => [alarmId];
}

class AlarmToggling extends AlarmState {}

class AlarmToggled extends AlarmState {
  final Alarm alarm;

  const AlarmToggled({required this.alarm});

  @override
  List<Object> get props => [alarm];
}
