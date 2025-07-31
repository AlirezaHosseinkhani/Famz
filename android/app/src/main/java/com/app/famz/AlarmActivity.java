package com.app.famz;

import android.app.AlarmManager;
import android.app.KeyguardManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.VibrationEffect;
import android.os.Vibrator;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.VideoView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class AlarmActivity extends AppCompatActivity {
    private static final String TAG = "AlarmActivity";
    private static final int SNOOZE_DURATION = 9 * 60 * 1000; // 9 minutes in milliseconds

    private VideoView videoView;
    private TextView timeTextView;
    private TextView dateTextView;
    private ImageView logoImageView;
    private Button snoozeButton;
    private Button stopButton;

    private Vibrator vibrator;
    private MediaPlayer mediaPlayer;
    private Handler timeHandler;
    private Runnable timeRunnable;
    private boolean isAlarmStopped = false;
    private String alarmId;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Set up to show on lock screen
        setupShowOnLockScreen();

        setContentView(R.layout.activity_alarm);

        String videoPath = getIntent().getStringExtra("videoPath");
        alarmId = getIntent().getStringExtra("alarmId");

        Log.d(TAG, "Alarm activity started with video: " + videoPath);

        // Initialize UI components
        initializeViews();

        // Start time updates
        startTimeUpdates();

        // Start vibration
        startVibration();

        // Set up video
        setupVideo(videoPath);

        // Set up button listeners
        setupButtonListeners();
    }

    private void initializeViews() {
        videoView = findViewById(R.id.videoView);
        timeTextView = findViewById(R.id.timeTextView);
        dateTextView = findViewById(R.id.dateTextView);
//        logoImageView = findViewById(R.id.logoImageView);
        snoozeButton = findViewById(R.id.snoozeButton);
        stopButton = findViewById(R.id.stopButton);
    }

    private void startTimeUpdates() {
        timeHandler = new Handler();
        timeRunnable = new Runnable() {
            @Override
            public void run() {
                updateDateTime();
                timeHandler.postDelayed(this, 1000); // Update every second
            }
        };
        timeHandler.post(timeRunnable);
    }

    private void updateDateTime() {
        Date now = new Date();

        // Format time (HH:mm)
        SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm", Locale.getDefault());
        timeTextView.setText(timeFormat.format(now));

        // Format date (e.g., "Monday, January 15")
        SimpleDateFormat dateFormat = new SimpleDateFormat("EEEE, MMMM d", Locale.getDefault());
        dateTextView.setText(dateFormat.format(now));
    }

    private void setupVideo(String videoPath) {
        if (videoPath != null && !videoPath.isEmpty()) {
            try {
                Uri videoUri = Uri.parse(videoPath);
                videoView.setVideoURI(videoUri);
                videoView.setOnPreparedListener(mp -> {
                    mp.setLooping(true);
                    videoView.start();
                });
                videoView.setOnErrorListener((mp, what, extra) -> {
                    Log.e(TAG, "Video error: " + what + ", " + extra);
                    // Fall back to audio only
                    playFallbackAudio();
                    return true;
                });
            } catch (Exception e) {
                Log.e(TAG, "Error playing video", e);
                playFallbackAudio();
            }
        } else {
            // No video path, fall back to audio
            playFallbackAudio();
        }
    }

    private void setupButtonListeners() {
        snoozeButton.setOnClickListener(v -> snoozeAlarm());

        stopButton.setOnClickListener(v -> {
            stopAlarm();
            finishAndRemoveTask(); // This removes from recent apps
        });
    }

    private void snoozeAlarm() {
        Log.d(TAG, "Snoozing alarm for 9 minutes");

        // Stop current alarm
        stopAlarmComponents();

        // Schedule snooze alarm
        scheduleSnoozeAlarm();

        // Finish activity
        finishAndRemoveTask();
    }

    private void scheduleSnoozeAlarm() {
        try {
            // Calculate snooze time
            long snoozeTime = System.currentTimeMillis() + SNOOZE_DURATION;

            // Create snooze alarm
            AlarmManager alarmManager = (AlarmManager) getSystemService(Context.ALARM_SERVICE);
            Intent intent = new Intent(this, AlarmReceiver.class);
            intent.setAction(AlarmReceiver.ACTION_ALARM);
            intent.putExtra("alarmId", alarmId + "_snooze_" + System.currentTimeMillis());
            intent.putExtra("videoPath", getIntent().getStringExtra("videoPath"));
            intent.putExtra("isSnooze", true);

            int requestCode = (alarmId + "_snooze").hashCode();
            PendingIntent pendingIntent = PendingIntent.getBroadcast(
                    this,
                    requestCode,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        snoozeTime,
                        pendingIntent);
            } else {
                alarmManager.setExact(
                        AlarmManager.RTC_WAKEUP,
                        snoozeTime,
                        pendingIntent);
            }

            Log.d(TAG, "Snooze alarm scheduled for: " + new Date(snoozeTime));
        } catch (Exception e) {
            Log.e(TAG, "Error scheduling snooze", e);
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        if (!isAlarmStopped) {
            stopAlarmComponents();
        }

        // Stop time updates
        if (timeHandler != null && timeRunnable != null) {
            timeHandler.removeCallbacks(timeRunnable);
        }
    }

    @Override
    public void onBackPressed() {
        // Prevent back button from closing alarm
        // User must use Stop or Snooze buttons
    }

    private void setupShowOnLockScreen() {
        // For showing activity on lock screen
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true);
            setTurnScreenOn(true);
            KeyguardManager keyguardManager = (KeyguardManager) getSystemService(Context.KEYGUARD_SERVICE);
            if (keyguardManager != null) {
                keyguardManager.requestDismissKeyguard(this, null);
            }
        } else {
            Window window = getWindow();
            window.addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
                    | WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
                    | WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                    | WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON);
        }
    }

    private void startVibration() {
        vibrator = (Vibrator) getSystemService(Context.VIBRATOR_SERVICE);

        long[] pattern = {0, 1000, 1000}; // Start, vibrate, sleep

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createWaveform(pattern, 0));
        } else {
            vibrator.vibrate(pattern, 0);
        }
    }

    private void playFallbackAudio() {
        try {
            mediaPlayer = MediaPlayer.create(this, R.raw.alarm_sound);
            if (mediaPlayer != null) {
                mediaPlayer.setLooping(true);

                // Set volume to maximum
                AudioManager audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
                if (audioManager != null) {
                    audioManager.setStreamVolume(
                            AudioManager.STREAM_MUSIC,
                            audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC),
                            0);
                }

                mediaPlayer.start();
            }
        } catch (Exception e) {
            Log.e(TAG, "Error playing fallback audio", e);
        }
    }

    private void stopAlarm() {
        stopAlarmComponents();

        // Stop service
        Intent serviceIntent = new Intent(this, AlarmService.class);
        stopService(serviceIntent);
    }

    private void stopAlarmComponents() {
        isAlarmStopped = true;

        // Stop vibration
        if (vibrator != null) {
            vibrator.cancel();
        }

        // Stop video
        if (videoView != null) {
            videoView.stopPlayback();
        }

        // Stop audio
        if (mediaPlayer != null) {
            try {
                if (mediaPlayer.isPlaying()) {
                    mediaPlayer.stop();
                }
                mediaPlayer.release();
                mediaPlayer = null;
            } catch (Exception e) {
                Log.e(TAG, "Error stopping media player", e);
            }
        }
    }
}