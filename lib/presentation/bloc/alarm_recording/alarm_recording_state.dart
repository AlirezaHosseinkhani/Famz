import 'package:equatable/equatable.dart';

import '../../../domain/entities/alarm_recording.dart';

abstract class AlarmRecordingState extends Equatable {
  const AlarmRecordingState();

  @override
  List<Object> get props => [];
}

class AlarmRecordingInitial extends AlarmRecordingState {}

class AlarmRecordingLoading extends AlarmRecordingState {}

class AlarmRecordingLoaded extends AlarmRecordingState {
  final List<AlarmRecording> recordings;

  const AlarmRecordingLoaded({required this.recordings});

  @override
  List<Object> get props => [recordings];
}

class AlarmRecordingError extends AlarmRecordingState {
  final String message;

  const AlarmRecordingError({required this.message});

  @override
  List<Object> get props => [message];
}
