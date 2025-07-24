import '../../repositories/alarm_repository.dart';

class DeleteAlarmUseCase {
  final AlarmRepository repository;

  DeleteAlarmUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteAlarm(id);
  }
}
