import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/alarm.dart';
import '../../repositories/alarm_repository.dart';

class ToggleAlarmUseCase {
  final AlarmRepository repository;

  ToggleAlarmUseCase(this.repository);

  Future<Either<Failure, Alarm>> call(ToggleAlarmParams params) async {
    return await repository.toggleAlarm(params.id, params.isActive);
  }
}

class ToggleAlarmParams {
  final int id;
  final bool isActive;

  ToggleAlarmParams({
    required this.id,
    required this.isActive,
  });
}
