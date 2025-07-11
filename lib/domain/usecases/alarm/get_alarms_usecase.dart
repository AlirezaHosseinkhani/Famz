import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/alarm.dart';
import '../../repositories/alarm_repository.dart';

class GetAlarmsUseCase {
  final AlarmRepository repository;

  GetAlarmsUseCase(this.repository);

  Future<Either<Failure, List<Alarm>>> call() async {
    return await repository.getAlarms();
  }
}
