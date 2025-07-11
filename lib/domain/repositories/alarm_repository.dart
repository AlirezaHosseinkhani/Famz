import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/alarm.dart';

abstract class AlarmRepository {
  Future<Either<Failure, Alarm>> createAlarm();

  Future<Either<Failure, Alarm>> deleteAlarm(int alarmId);

  Future<Either<Failure, List<Alarm>>> getAlarms();

  Future<Either<Failure, Alarm>> toggleAlarm();

  Future<Either<Failure, Alarm>> updateAlarm();
}
