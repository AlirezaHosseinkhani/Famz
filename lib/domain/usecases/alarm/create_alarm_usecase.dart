import '../../entities/alarm.dart';
import '../../repositories/alarm_repository.dart';

class CreateAlarmUseCase {
  final AlarmRepository repository;

  CreateAlarmUseCase(this.repository);

  Future<void> call(Alarm alarm) async {
    return await repository.saveAlarm(alarm);
  }
}
