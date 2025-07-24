import '../../entities/alarm.dart';
import '../../repositories/alarm_repository.dart';

class UpdateAlarmUseCase {
  final AlarmRepository repository;

  UpdateAlarmUseCase(this.repository);

  Future<void> call(Alarm alarm) async {
    return await repository.saveAlarm(alarm);
  }
}
