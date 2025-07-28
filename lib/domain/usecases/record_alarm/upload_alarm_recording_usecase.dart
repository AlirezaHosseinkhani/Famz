import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/record_alarm_request.dart';
import '../../repositories/record_alarm_repository.dart';

class UploadAlarmRecordingUseCase {
  final RecordAlarmRepository repository;

  UploadAlarmRecordingUseCase(this.repository);

  Future<Either<Failure, RecordAlarmRequest>> call({
    required int requestId,
    required String recordingType,
    File? audioFile,
    File? videoFile,
    required Duration duration,
  }) async {
    return await repository.uploadRecording(
      requestId: requestId,
      recordingType: recordingType,
      audioFile: audioFile,
      videoFile: videoFile,
      duration: duration,
    );
  }
}
