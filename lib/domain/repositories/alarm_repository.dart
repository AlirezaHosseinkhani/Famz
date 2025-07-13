import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/alarm.dart';

abstract class AlarmRepository {
  Future<Either<Failure, Alarm>> createAlarm({
    required DateTime time,
    required bool isActive,
    int? recordingId,
    List<int>? repeatDays,
    String? label,
  });

  Future<Either<Failure, bool>> deleteAlarm(int alarmId);

  Future<Either<Failure, List<Alarm>>> getAlarms();

  Future<Either<Failure, Alarm>> toggleAlarm(int id, bool isActive);

  Future<Either<Failure, Alarm>> updateAlarm({
    required int id,
    DateTime? time,
    bool? isActive,
    int? recordingId,
    List<int>? repeatDays,
    String? label,
  });
}
