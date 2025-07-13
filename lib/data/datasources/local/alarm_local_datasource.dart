import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/errors/exceptions.dart';
import '../../models/alarm/alarm_model.dart';

abstract class AlarmLocalDataSource {
  Future<List<AlarmModel>> getCachedAlarms();

  Future<void> cacheAlarms(List<AlarmModel> alarms);

  Future<void> cacheAlarm(AlarmModel alarm);

  Future<void> deleteAlarm(int alarmId);
}

const String CACHED_ALARMS = 'CACHED_ALARMS';

class AlarmLocalDataSourceImpl implements AlarmLocalDataSource {
  final SharedPreferences sharedPreferences;

  AlarmLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheAlarm(AlarmModel alarm) async {
    try {
      final cachedAlarms = await getCachedAlarms();
      final existingIndex = cachedAlarms.indexWhere((a) => a.id == alarm.id);

      if (existingIndex != -1) {
        cachedAlarms[existingIndex] = alarm;
      } else {
        cachedAlarms.add(alarm);
      }

      await cacheAlarms(cachedAlarms);
    } catch (e) {
      throw CacheException('Failed to cache alarm');
    }
  }

  @override
  Future<void> cacheAlarms(List<AlarmModel> alarms) async {
    try {
      final alarmsJson = alarms.map((alarm) => alarm.toJson()).toList();
      await sharedPreferences.setString(
        CACHED_ALARMS,
        json.encode(alarmsJson),
      );
    } catch (e) {
      throw CacheException('Failed to cache alarms');
    }
  }

  @override
  Future<void> deleteAlarm(int alarmId) async {
    try {
      final cachedAlarms = await getCachedAlarms();
      cachedAlarms.removeWhere((alarm) => alarm.id == alarmId);
      await cacheAlarms(cachedAlarms);
    } catch (e) {
      throw CacheException('Failed to delete alarm from cache');
    }
  }

  @override
  Future<List<AlarmModel>> getCachedAlarms() async {
    try {
      final jsonString = sharedPreferences.getString(CACHED_ALARMS);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList
            .map((alarmJson) => AlarmModel.fromJson(alarmJson))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw CacheException('Failed to get cached alarms');
    }
  }
}
