import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/alarm.dart';

class AlarmService {
  static const platform = MethodChannel('com.app.famz/alarm');

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize
  Future<void> init() async {
    // Initialize flutter local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    // Request permissions
    await requestPermissions();
  }

  Future<void> requestPermissions() async {
    // Request notification permissions
    if (Platform.isAndroid) {
      // Request Android permissions
      await Permission.notification.request();
      await Permission.scheduleExactAlarm.request();

      if (Platform.isAndroid &&
          await Permission.ignoreBatteryOptimizations.isGranted == false) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    }
  }

  Future<void> scheduleAlarm(Alarm alarm) async {
    try {
      if (alarm.isRecurring) {
        // For recurring alarms, we need a different approach
        await _scheduleRecurringAlarm(alarm, '');
      } else {
        // For one-time alarms
        final timestamp = alarm.scheduledTime.millisecondsSinceEpoch;

        // Only schedule if the time is in the future
        if (timestamp > DateTime.now().millisecondsSinceEpoch) {
          await platform.invokeMethod('scheduleAlarm', {
            'alarmId': alarm.id,
            'timestamp': timestamp,
            'videoPath': alarm.videoPath,
            'timeZone': '',
            'isRecurring': false,
            'weekdays': null,
          });

          debugPrint(
              'Scheduled one-time alarm: ${alarm.id} at ${alarm.scheduledTime}');

          // Also schedule a notification as a fallback
          await _scheduleNotification(alarm);
        } else {
          debugPrint(
              'Cannot schedule alarm in the past: ${alarm.scheduledTime}');
        }
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to schedule alarm: ${e.message}');
      rethrow;
    }
  }

  // New implementation of _scheduleRecurringAlarm
  Future<void> _scheduleRecurringAlarm(Alarm alarm, String timeZone) async {
    // Get the hour and minute from the scheduled time
    final hour = alarm.scheduledTime.hour;
    final minute = alarm.scheduledTime.minute;

    // For debugging
    debugPrint('Scheduling recurring alarm: ${alarm.id}');
    debugPrint('Selected days: ${alarm.weekdays}');

    // For each selected weekday, schedule an alarm
    for (int i = 0; i < 7; i++) {
      if (alarm.weekdays[i]) {
        // Convert to Android weekday format (1 = Monday, 7 = Sunday)
        int androidWeekday = i + 1;

        // Calculate the next occurrence of this weekday
        final nextOccurrence =
            _getNextWeekdayOccurrence(androidWeekday, hour, minute);

        // Create a unique ID for this weekday's alarm
        final weekdayAlarmId = '${alarm.id}_$i';

        debugPrint(
            'Scheduling for day $i (Android day $androidWeekday): ${nextOccurrence.toIso8601String()}');

        // Schedule this specific day's alarm
        await platform.invokeMethod('scheduleAlarm', {
          'alarmId': weekdayAlarmId,
          'timestamp': nextOccurrence.millisecondsSinceEpoch,
          'videoPath': alarm.videoPath,
          'timeZone': timeZone,
          'isRecurring': true,
          'weekday': i,
          'hour': hour,
          'minute': minute,
          'recurringId': alarm.id,
        });

        debugPrint(
            'Scheduled recurring alarm for day $i: $weekdayAlarmId at $nextOccurrence');
      }
    }
  }

  // Helper to calculate the next occurrence of a specific weekday at a specific time
  DateTime _getNextWeekdayOccurrence(int weekday, int hour, int minute) {
    DateTime now = DateTime.now();

    // Create a datetime for today with the target hour and minute
    DateTime targetTime =
        DateTime(now.year, now.month, now.day, hour, minute, 0);

    // Calculate days until the next occurrence of the target weekday
    int daysUntilTargetWeekday = weekday - now.weekday;
    if (daysUntilTargetWeekday < 0) {
      daysUntilTargetWeekday += 7;
    } else if (daysUntilTargetWeekday == 0 && now.isAfter(targetTime)) {
      // If today is the target weekday but the time has already passed, go to next week
      daysUntilTargetWeekday = 7;
    }

    // Add the days to get to the next occurrence
    return targetTime.add(Duration(days: daysUntilTargetWeekday));
  }

  Future<void> cancelAlarm(String id) async {
    try {
      // For recurring alarms, cancel each weekday alarm
      for (int weekday = 0; weekday < 7; weekday++) {
        final String alarmIdForDay = '${id}_$weekday';
        await platform.invokeMethod('cancelAlarm', {
          'alarmId': alarmIdForDay,
        });
      }

      // Also cancel the main alarm ID
      await platform.invokeMethod('cancelAlarm', {
        'alarmId': id,
      });

      // Also cancel notification
      await flutterLocalNotificationsPlugin.cancel(id.hashCode);
    } on PlatformException catch (e) {
      debugPrint('Failed to cancel alarm: ${e.message}');
    }
  }

  // Schedule a notification as a fallback
  Future<void> _scheduleNotification(Alarm alarm) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'alarm_channel',
      'Alarm Notifications',
      channelDescription: 'Used for alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      fullScreenIntent: true,
    );

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    final scheduledTime = tz.TZDateTime.from(alarm.scheduledTime, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      alarm.id.hashCode,
      'Alarm',
      'Your alarm is going off',
      scheduledTime,
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
