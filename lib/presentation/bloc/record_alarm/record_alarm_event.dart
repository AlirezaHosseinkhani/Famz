import 'dart:io';

abstract class RecordAlarmEvent {}

class StartRecordingEvent extends RecordAlarmEvent {
  final String recordingType; // 'audio' or 'video'
  final int? cameraIndex;

  StartRecordingEvent({
    required this.recordingType,
    this.cameraIndex,
  });
}

class StopRecordingEvent extends RecordAlarmEvent {}

class PauseRecordingEvent extends RecordAlarmEvent {}

class ResumeRecordingEvent extends RecordAlarmEvent {}

class PlayRecordingEvent extends RecordAlarmEvent {}

class StopPlaybackEvent extends RecordAlarmEvent {}

class UploadRecordingEvent extends RecordAlarmEvent {
  final int requestId;
  final String recordingType;
  final File? audioFile;
  final File? videoFile;
  final Duration duration;

  UploadRecordingEvent({
    required this.requestId,
    required this.recordingType,
    this.audioFile,
    this.videoFile,
    required this.duration,
  });
}

class DeleteRecordingEvent extends RecordAlarmEvent {
  final int recordingId;

  DeleteRecordingEvent({required this.recordingId});
}

class ResetRecordingEvent extends RecordAlarmEvent {}

class SwitchRecordingTypeEvent extends RecordAlarmEvent {
  final String recordingType;

  SwitchRecordingTypeEvent({required this.recordingType});
}

class SwitchCameraEvent extends RecordAlarmEvent {
  final int cameraIndex;

  SwitchCameraEvent({required this.cameraIndex});
}

class InitializeCameraEvent extends RecordAlarmEvent {
  final int cameraIndex;

  InitializeCameraEvent({required this.cameraIndex});
}

class UpdateRecordingDurationEvent extends RecordAlarmEvent {
  final Duration duration;

  UpdateRecordingDurationEvent({required this.duration});
}

class UpdatePlaybackPositionEvent extends RecordAlarmEvent {
  final Duration position;

  UpdatePlaybackPositionEvent({required this.position});
}
