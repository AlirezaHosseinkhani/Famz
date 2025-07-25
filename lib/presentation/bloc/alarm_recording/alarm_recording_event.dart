import 'package:equatable/equatable.dart';

import '../../../domain/entities/alarm_recording.dart';

abstract class AlarmRecordingEvent extends Equatable {
  const AlarmRecordingEvent();

  @override
  List<Object> get props => [];
}

class LoadRecordingsEvent extends AlarmRecordingEvent {}

class DownloadRecordingEvent extends AlarmRecordingEvent {
  final AlarmRecording recording;

  const DownloadRecordingEvent({required this.recording});

  @override
  List<Object> get props => [recording];
}

class UpdateRecordingProgressEvent extends AlarmRecordingEvent {
  final int recordingId;
  final double progress;

  const UpdateRecordingProgressEvent({
    required this.recordingId,
    required this.progress,
  });

  @override
  List<Object> get props => [recordingId, progress];
}

class RecordingDownloadedEvent extends AlarmRecordingEvent {
  final int recordingId;
  final String localPath;

  const RecordingDownloadedEvent({
    required this.recordingId,
    required this.localPath,
  });

  @override
  List<Object> get props => [recordingId, localPath];
}
