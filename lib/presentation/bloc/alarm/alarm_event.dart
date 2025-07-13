import 'package:equatable/equatable.dart';

abstract class AlarmEvent extends Equatable {
  const AlarmEvent();

  @override
  List<Object?> get props => [];
}

class LoadAlarmsEvent extends AlarmEvent {}

class CreateAlarmEvent extends AlarmEvent {
  final DateTime time;
  final bool isActive;
  final int? recordingId;
  final List<int>? repeatDays;
  final String? label;

  const CreateAlarmEvent({
    required this.time,
    required this.isActive,
    this.recordingId,
    this.repeatDays,
    this.label,
  });

  @override
  List<Object?> get props => [time, isActive, recordingId, repeatDays, label];
}

class UpdateAlarmEvent extends AlarmEvent {
  final int id;
  final DateTime? time;
  final bool? isActive;
  final int? recordingId;
  final List<int>? repeatDays;
  final String? label;

  const UpdateAlarmEvent({
    required this.id,
    this.time,
    this.isActive,
    this.recordingId,
    this.repeatDays,
    this.label,
  });

  @override
  List<Object?> get props =>
      [id, time, isActive, recordingId, repeatDays, label];
}

class DeleteAlarmEvent extends AlarmEvent {
  final int alarmId;

  const DeleteAlarmEvent({required this.alarmId});

  @override
  List<Object> get props => [alarmId];
}

class ToggleAlarmEvent extends AlarmEvent {
  final int alarmId;
  final bool isActive;

  const ToggleAlarmEvent({
    required this.alarmId,
    required this.isActive,
  });

  @override
  List<Object> get props => [alarmId, isActive];
}

class RefreshAlarmsEvent extends AlarmEvent {}
