import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/alarm/alarm_model.dart';

abstract class AlarmLocalDataSource {
  Future<List<AlarmModel>> getAlarms();
  Future<void> saveAlarms(List<AlarmModel> alarms);
  Future<void> deleteAlarm(String id);
}

class AlarmLocalDataSourceImpl implements AlarmLocalDataSource {
  static const String ALARMS_KEY = 'alarms';
  final SharedPreferences sharedPreferences;

  AlarmLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<AlarmModel>> getAlarms() async {
    final alarmsJson = sharedPreferences.getStringList(ALARMS_KEY) ?? [];
    return alarmsJson
        .map((alarmJson) => AlarmModel.fromJson(jsonDecode(alarmJson)))
        .toList();
  }

  @override
  Future<void> saveAlarms(List<AlarmModel> alarms) async {
    final alarmsJson = alarms.map((a) => jsonEncode(a.toJson())).toList();
    await sharedPreferences.setStringList(ALARMS_KEY, alarmsJson);
  }

  @override
  Future<void> deleteAlarm(String id) async {
    final alarms = await getAlarms();
    final filteredAlarms = alarms.where((alarm) => alarm.id != id).toList();
    await saveAlarms(filteredAlarms);
  }
}
