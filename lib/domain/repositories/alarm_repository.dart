import '../entities/alarm.dart';

abstract class AlarmRepository {
  Future<List<Alarm>> getAlarms();
  Future<void> saveAlarm(Alarm alarm);
  Future<void> deleteAlarm(String id);
  Future<void> toggleAlarm(String id, bool isActive);
  Future<void> scheduleAlarm(Alarm alarm);
  Future<void> cancelAlarm(String id);
  Future<void> init();
}
