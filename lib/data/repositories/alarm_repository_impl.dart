import '../../core/services/alarm_service.dart';
import '../../domain/entities/alarm.dart';
import '../../domain/repositories/alarm_repository.dart';
import '../datasources/local/alarm_local_datasource.dart';
import '../models/alarm/alarm_model.dart';

class AlarmRepositoryImpl implements AlarmRepository {
  final AlarmLocalDataSource localDataSource;
  final AlarmService alarmService;

  AlarmRepositoryImpl({
    required this.localDataSource,
    required this.alarmService,
  });

  @override
  Future<void> init() async {
    await alarmService.init();
  }

  @override
  Future<List<Alarm>> getAlarms() async {
    final alarmModels = await localDataSource.getAlarms();
    return alarmModels.cast<Alarm>();
  }

  @override
  Future<void> saveAlarm(Alarm alarm) async {
    final alarms = await localDataSource.getAlarms();
    final alarmModel = AlarmModel.fromEntity(alarm);

    // Check if alarm with this ID already exists
    final existingIndex = alarms.indexWhere((a) => a.id == alarm.id);

    if (existingIndex >= 0) {
      alarms[existingIndex] = alarmModel;
    } else {
      alarms.add(alarmModel);
    }

    await localDataSource.saveAlarms(alarms);

    // Schedule alarm using alarm service
    if (alarm.isActive) {
      await alarmService.scheduleAlarm(alarm);
    } else {
      await alarmService.cancelAlarm(alarm.id!);
    }
  }

  @override
  Future<void> deleteAlarm(String id) async {
    await alarmService.cancelAlarm(id);
    await localDataSource.deleteAlarm(id);
  }

  @override
  Future<void> toggleAlarm(String id, bool isActive) async {
    final alarms = await localDataSource.getAlarms();
    final alarmIndex = alarms.indexWhere((a) => a.id == id);

    if (alarmIndex >= 0) {
      final alarm = alarms[alarmIndex];
      final updatedAlarm = AlarmModel(
        id: alarm.id,
        scheduledTime: alarm.scheduledTime,
        videoPath: alarm.videoPath,
        isActive: isActive,
        isRecurring: alarm.isRecurring,
        weekdays: alarm.weekdays,
      );

      alarms[alarmIndex] = updatedAlarm;
      await localDataSource.saveAlarms(alarms);

      if (isActive) {
        await alarmService.scheduleAlarm(updatedAlarm);
      } else {
        await alarmService.cancelAlarm(id);
      }
    }
  }

  @override
  Future<void> scheduleAlarm(Alarm alarm) async {
    await alarmService.scheduleAlarm(alarm);
  }

  @override
  Future<void> cancelAlarm(String id) async {
    await alarmService.cancelAlarm(id);
  }
}
