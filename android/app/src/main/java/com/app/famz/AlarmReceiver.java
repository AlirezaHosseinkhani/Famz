package com.app.famz;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;

import java.util.Calendar;

public class AlarmReceiver extends BroadcastReceiver {
    public static final String TAG = "AlarmReceiver";
    public static final String ACTION_ALARM = "com.app.famz.ALARM";

    @Override
    public void onReceive(Context context, Intent intent) {
        Log.d(TAG, "Alarm received: " + intent.getAction());

        if (intent.getAction() != null) {
            if (intent.getAction().equals(ACTION_ALARM)) {
                String videoPath = intent.getStringExtra("videoPath");
                String alarmId = intent.getStringExtra("alarmId");
                boolean isRecurring = intent.getBooleanExtra("isRecurring", false);

                // Start service to handle the alarm
                Intent serviceIntent = new Intent(context, AlarmService.class);
                serviceIntent.putExtra("videoPath", videoPath);
                serviceIntent.putExtra("alarmId", alarmId);

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(serviceIntent);
                } else {
                    context.startService(serviceIntent);
                }

                // If this is a recurring alarm, reschedule for next week
                if (isRecurring) {
                    int weekday = intent.getIntExtra("weekday", -1);
                    int hour = intent.getIntExtra("hour", -1);
                    int minute = intent.getIntExtra("minute", -1);
                    String recurringId = intent.getStringExtra("recurringId");

                    if (weekday >= 0 && hour >= 0 && minute >= 0) {
                        scheduleNextWeekAlarm(context, alarmId, weekday, hour, minute, videoPath, recurringId);
                    }
                }
            } else if (intent.getAction().equals(Intent.ACTION_BOOT_COMPLETED) ||
                    intent.getAction().equals(Intent.ACTION_MY_PACKAGE_REPLACED)) {
                // Reschedule alarms after boot or app update
                Log.d(TAG, "Boot completed or app updated, should reschedule alarms");
            }
        }
    }

    private void scheduleNextWeekAlarm(Context context, String alarmId, int weekday,
                                       int hour, int minute, String videoPath, String recurringId) {
        try {
            AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);

            // Create intent for next week
            Intent intent = new Intent(context, AlarmReceiver.class);
            intent.setAction(ACTION_ALARM);
            intent.putExtra("alarmId", alarmId);
            intent.putExtra("videoPath", videoPath);
            intent.putExtra("isRecurring", true);
            intent.putExtra("weekday", weekday);
            intent.putExtra("hour", hour);
            intent.putExtra("minute", minute);
            intent.putExtra("recurringId", recurringId);

            // Create pending intent
            int requestCode = alarmId.hashCode();
            PendingIntent pendingIntent = PendingIntent.getBroadcast(
                    context,
                    requestCode,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

            // Calculate time for next week
            Calendar calendar = Calendar.getInstance();

            // Add 7 days (one week)
            calendar.add(Calendar.DAY_OF_YEAR, 7);

            // Set the hour and minute
            calendar.set(Calendar.HOUR_OF_DAY, hour);
            calendar.set(Calendar.MINUTE, minute);
            calendar.set(Calendar.SECOND, 0);
            calendar.set(Calendar.MILLISECOND, 0);

            // Schedule the alarm
            long nextAlarmTime = calendar.getTimeInMillis();

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        nextAlarmTime,
                        pendingIntent);
            } else {
                alarmManager.setExact(
                        AlarmManager.RTC_WAKEUP,
                        nextAlarmTime,
                        pendingIntent);
            }

            Log.d(TAG, "Rescheduled recurring alarm for next week: " + alarmId +
                    " at " + calendar.getTime().toString());

        } catch (Exception e) {
            Log.e(TAG, "Error scheduling next week alarm", e);
        }
    }
}