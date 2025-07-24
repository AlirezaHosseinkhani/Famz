import '../../entities/alarm.dart';
import '../../repositories/alarm_repository.dart';

class GetAlarmsUseCase {
  final AlarmRepository repository;

  GetAlarmsUseCase(this.repository);

  Future<List<Alarm>> call() async {
    return await repository.getAlarms();
  }
}
