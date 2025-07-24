import 'package:equatable/equatable.dart';

import '../../../domain/entities/alarm.dart';

abstract class AlarmEvent extends Equatable {
  const AlarmEvent();

  @override
  List<Object> get props => [];
}

class LoadAlarmsEvent extends AlarmEvent {}

class RefreshAlarmsEvent extends AlarmEvent {}

class CreateAlarmEvent extends AlarmEvent {
  final Alarm alarm;

  const CreateAlarmEvent({required this.alarm});

  @override
  List<Object> get props => [alarm];
}

class UpdateAlarmEvent extends AlarmEvent {
  final Alarm alarm;

  const UpdateAlarmEvent({required this.alarm});

  @override
  List<Object> get props => [alarm];
}

class DeleteAlarmEvent extends AlarmEvent {
  final String alarmId;

  const DeleteAlarmEvent({required this.alarmId});

  @override
  List<Object> get props => [alarmId];
}

class ToggleAlarmEvent extends AlarmEvent {
  final String alarmId;
  final bool isActive;

  const ToggleAlarmEvent({
    required this.alarmId,
    required this.isActive,
  });

  @override
  List<Object> get props => [alarmId, isActive];
}

class InitializeAlarmServiceEvent extends AlarmEvent {}
