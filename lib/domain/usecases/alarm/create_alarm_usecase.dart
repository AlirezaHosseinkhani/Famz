import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/alarm.dart';
import '../../repositories/alarm_repository.dart';

class CreateAlarmUseCase {
  final AlarmRepository repository;

  CreateAlarmUseCase(this.repository);

  Future<Either<Failure, Alarm>> call(CreateAlarmParams params) async {
    return await repository.createAlarm(
        // time: params.time,
        // isActive: params.isActive,
        // recordingId: params.recordingId,
        // repeatDays: params.repeatDays,
        // label: params.label,
        );
  }
}

class CreateAlarmParams {
  final DateTime time;
  final bool isActive;
  final int? recordingId;
  final List<int>? repeatDays;
  final String? label;

  CreateAlarmParams({
    required this.time,
    required this.isActive,
    this.recordingId,
    this.repeatDays,
    this.label,
  });
}
