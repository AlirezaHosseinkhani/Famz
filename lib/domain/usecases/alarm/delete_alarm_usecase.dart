import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/alarm_repository.dart';

class DeleteAlarmUseCase {
  final AlarmRepository repository;

  DeleteAlarmUseCase(this.repository);

  Future<Either<Failure, void>> call(int alarmId) async {
    return await repository.deleteAlarm(alarmId);
  }
}
