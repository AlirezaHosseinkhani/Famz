import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/alarm.dart';
import '../../repositories/alarm_repository.dart';

class UpdateAlarmUseCase {
  final AlarmRepository repository;

  UpdateAlarmUseCase(this.repository);

  Future<Either<Failure, Alarm>> call(UpdateAlarmParams params) async {
    return await repository.updateAlarm(
        // id: params.id,
        // time: params.time,
        // isActive: params.isActive,
        // recordingId: params.recordingId,
        // repeatDays: params.repeatDays,
        // label: params.label,
        );
  }
}

class UpdateAlarmParams {
  final int id;
  final DateTime? time;
  final bool? isActive;
  final int? recordingId;
  final List<int>? repeatDays;
  final String? label;

  UpdateAlarmParams({
    required this.id,
    this.time,
    this.isActive,
    this.recordingId,
    this.repeatDays,
    this.label,
  });
}
