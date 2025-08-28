import 'dart:io';

import '../../../domain/entities/record_alarm_request.dart';

abstract class RecordAlarmState {}

class RecordAlarmInitial extends RecordAlarmState {}

class RecordAlarmLoading extends RecordAlarmState {
  final String message;

  RecordAlarmLoading({this.message = 'Loading...'});
}

class CameraInitialized extends RecordAlarmState {
  final int cameraIndex;
  final String recordingType;

  CameraInitialized({
    required this.cameraIndex,
    required this.recordingType,
  });
}

class CameraInitializationFailed extends RecordAlarmState {
  final String error;

  CameraInitializationFailed({required this.error});
}

class RecordingInProgress extends RecordAlarmState {
  final String recordingType;
  final Duration duration;
  final bool isPaused;
  final int? cameraIndex;

  RecordingInProgress({
    required this.recordingType,
    required this.duration,
    this.isPaused = false,
    this.cameraIndex,
  });
}

class RecordingCompleted extends RecordAlarmState {
  final String recordingType;
  final File? audioFile;
  final File? videoFile;
  final Duration duration;
  final String filePath;

  RecordingCompleted({
    required this.recordingType,
    this.audioFile,
    this.videoFile,
    required this.duration,
    required this.filePath,
  });
}

class PlayingRecording extends RecordAlarmState {
  final String recordingType;
  final File? audioFile;
  final File? videoFile;
  final Duration currentPosition;
  final Duration totalDuration;
  final String filePath;

  PlayingRecording({
    required this.recordingType,
    this.audioFile,
    this.videoFile,
    required this.currentPosition,
    required this.totalDuration,
    required this.filePath,
  });
}

class UploadingRecording extends RecordAlarmState {
  final double progress;
  final String message;

  UploadingRecording({
    required this.progress,
    this.message = 'Uploading recording...',
  });
}

class RecordAlarmSuccess extends RecordAlarmState {
  final RecordAlarmRequest recording;
  final String message;

  RecordAlarmSuccess({
    required this.recording,
    required this.message,
  });
}

class RecordAlarmError extends RecordAlarmState {
  final String message;

  RecordAlarmError({required this.message});
}

class RecordingReset extends RecordAlarmState {}

class RecordingTypeChanged extends RecordAlarmState {
  final String recordingType;

  RecordingTypeChanged({required this.recordingType});
}

class CameraSwitched extends RecordAlarmState {
  final int cameraIndex;
  final String recordingType;

  CameraSwitched({
    required this.cameraIndex,
    required this.recordingType,
  });
}
