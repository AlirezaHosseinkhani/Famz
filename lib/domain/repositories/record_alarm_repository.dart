import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/record_alarm_request.dart';

abstract class RecordAlarmRepository {
  Future<Either<Failure, RecordAlarmRequest>> uploadRecording({
    required int requestId,
    required String recordingType,
    File? audioFile,
    File? videoFile,
    required Duration duration,
  });

  Future<Either<Failure, void>> deleteRecording(int recordingId);

  Future<Either<Failure, RecordAlarmRequest>> updateRecording({
    required int recordingId,
    required int requestId,
    required String recordingType,
    File? audioFile,
    File? videoFile,
    required Duration duration,
  });
}
