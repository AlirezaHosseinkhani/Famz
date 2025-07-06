// import 'package:equatable/equatable.dart';
//
// import '../../../domain/entities/alarm.dart';
//
// abstract class AlarmEvent extends Equatable {
//   const AlarmEvent();
//
//   @override
//   List<Object?> get props => [];
// }
//
// class GetAlarmsRequested extends AlarmEvent {
//   const GetAlarmsRequested();
// }
//
// class ToggleAlarmRequested extends AlarmEvent {
//   final int alarmId;
//   final bool isActive;
//
//   const ToggleAlarmRequested({
//     required this.alarmId,
//     required this.isActive,
//   });
//
//   @override
//   List<Object?> get props => [alarmId, isActive];
// }
//
// class DeleteAlarmRequested extends AlarmEvent {
//   final int alarmId;
//
//   const DeleteAlarmRequested({required this.alarmId});
//
//   @override
//   List<Object?> get props => [alarmId];
// }
//
// class CreateAlarmRequested extends AlarmEvent {
//   final Alarm alarm;
//
//   const CreateAlarmRequested({required this.alarm});
//
//   @override
//   List<Object?> get props => [alarm];
// }
//
// class UpdateAlarmRequested extends AlarmEvent {
//   final Alarm alarm;
//
//   const UpdateAlarmRequested({required this.alarm});
//
//   @override
//   List<Object?> get props => [alarm];
// }
import 'package:equatable/equatable.dart';

abstract class AlarmEvent extends Equatable {
  const AlarmEvent();

  @override
  List<Object?> get props => [];
}

class GetAlarmsRequested extends AlarmEvent {}

class ToggleAlarmRequested extends AlarmEvent {
  final int alarmId;
  final bool isActive;

  const ToggleAlarmRequested({
    required this.alarmId,
    required this.isActive,
  });

  @override
  List<Object> get props => [alarmId, isActive];
}

class DeleteAlarmRequested extends AlarmEvent {
  final int alarmId;

  const DeleteAlarmRequested({required this.alarmId});

  @override
  List<Object> get props => [alarmId];
}

class CreateAlarmRequested extends AlarmEvent {
  final String title;
  final DateTime dateTime;
  final String? audioUrl;
  final String? videoUrl;
  final String? description;
  final bool isRepeating;
  final List<int> repeatDays;
  final String ringtone;

  const CreateAlarmRequested({
    required this.title,
    required this.dateTime,
    this.audioUrl,
    this.videoUrl,
    this.description,
    required this.isRepeating,
    required this.repeatDays,
    required this.ringtone,
  });

  @override
  List<Object?> get props => [
        title,
        dateTime,
        audioUrl,
        videoUrl,
        description,
        isRepeating,
        repeatDays,
        ringtone,
      ];
}
