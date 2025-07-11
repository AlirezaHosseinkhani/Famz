import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/alarm.dart';

abstract class AlarmRecordingRepository {
  Future<Either<Failure, Alarm>> deleteRecording(int requestId);

  Future<Either<Failure, List<String>>> getRecordings();

  Future<Either<Failure, String>> updateRecording();

  Future<Either<Failure, String>> uploadRecording();
}
