package com.app.famz;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.TimeZone;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.app.famz/alarm";
    private static final String TAG = "MainActivity";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            switch (call.method) {
                                case "scheduleAlarm":
                                    scheduleAlarm(call, result);
                                    break;
                                case "cancelAlarm":
                                    cancelAlarm(call, result);
                                    break;
                                default:
                                    result.notImplemented();
                                    break;
                            }
                        }
                );
    }

    private void scheduleAlarm(MethodCall call, MethodChannel.Result result) {
        String alarmId = call.argument("alarmId");
        Long timestamp = call.argument("timestamp");
        String videoPath = call.argument("videoPath");
        String timeZoneName = call.argument("timeZone");
        Boolean isRecurring = call.argument("isRecurring");
        Integer weekday = call.argument("weekday");
        String recurringId = call.argument("recurringId");

        if (alarmId == null || timestamp == null || videoPath == null) {
            result.error("INVALID_ARGUMENT", "Missing required argument", null);
            return;
        }

        try {
            AlarmManager alarmManager = (AlarmManager) getSystemService(Context.ALARM_SERVICE);
            Intent intent = new Intent(this, AlarmReceiver.class);
            intent.setAction(AlarmReceiver.ACTION_ALARM);
            intent.putExtra("alarmId", alarmId);
            intent.putExtra("videoPath", videoPath);
            intent.putExtra("timestamp", timestamp);

            // Add recurring information if applicable
            if (isRecurring != null && isRecurring) {
                intent.putExtra("isRecurring", true);
                if (weekday != null) intent.putExtra("weekday", weekday);
                if (recurringId != null) intent.putExtra("recurringId", recurringId);
            }

            // Create a unique request code from the alarm ID
            int requestCode = alarmId.hashCode();

            PendingIntent pendingIntent = PendingIntent.getBroadcast(
                    this,
                    requestCode,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        timestamp,
                        pendingIntent);
            } else {
                alarmManager.setExact(
                        AlarmManager.RTC_WAKEUP,
                        timestamp,
                        pendingIntent);
            }

            Log.d(TAG, "Alarm scheduled: " + alarmId + " at " + timestamp);

            result.success(true);
        } catch (Exception e) {
            Log.e(TAG, "Error scheduling alarm", e);
            result.error("SCHEDULE_ERROR", e.getMessage(), null);
        }
    }

    private void cancelAlarm(MethodCall call, MethodChannel.Result result) {
        String alarmId = call.argument("alarmId");

        if (alarmId == null) {
            result.error("INVALID_ARGUMENT", "Missing alarmId", null);
            return;
        }

        try {
            AlarmManager alarmManager = (AlarmManager) getSystemService(Context.ALARM_SERVICE);
            Intent intent = new Intent(this, AlarmReceiver.class);
            intent.setAction(AlarmReceiver.ACTION_ALARM);

            // Use the same request code as when scheduling
            int requestCode = alarmId.hashCode();

            PendingIntent pendingIntent = PendingIntent.getBroadcast(
                    this,
                    requestCode,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

            alarmManager.cancel(pendingIntent);

            Log.d(TAG, "Alarm canceled: " + alarmId);

            result.success(true);
        } catch (Exception e) {
            Log.e(TAG, "Error canceling alarm", e);
            result.error("CANCEL_ERROR", e.getMessage(), null);
        }
    }
}