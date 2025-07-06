package com.app.famz;

import android.app.KeyguardManager;
import android.content.Context;
import android.content.Intent;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.VibrationEffect;
import android.os.Vibrator;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.VideoView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

public class AlarmActivity extends AppCompatActivity {
    private static final String TAG = "AlarmActivity";

    private VideoView videoView;
    private Vibrator vibrator;
    private MediaPlayer mediaPlayer;
    private boolean isAlarmStopped = false;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Set up to show on lock screen
        setupShowOnLockScreen();

        setContentView(R.layout.activity_alarm);

        String videoPath = getIntent().getStringExtra("videoPath");
        String alarmId = getIntent().getStringExtra("alarmId");

        Log.d(TAG, "Alarm activity started with video: " + videoPath);

        // Set up UI components
        videoView = findViewById(R.id.videoView);
        Button stopButton = findViewById(R.id.stopButton);

        // Start vibration
        startVibration();

        // Set up video
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

        // Set up stop button
        stopButton.setOnClickListener(v -> {
            stopAlarm();
            finish();
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        if (!isAlarmStopped) {
            stopAlarm();
        }
    }

    private void setupShowOnLockScreen() {
        // For showing activity on lock screen
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true);
            setTurnScreenOn(true);
            KeyguardManager keyguardManager = (KeyguardManager) getSystemService(Context.KEYGUARD_SERVICE);
            keyguardManager.requestDismissKeyguard(this, null);
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
            mediaPlayer.setLooping(true);

            // Set volume to maximum
            AudioManager audioManager = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
            audioManager.setStreamVolume(
                    AudioManager.STREAM_MUSIC,
                    audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC),
                    0);

            mediaPlayer.start();
        } catch (Exception e) {
            Log.e(TAG, "Error playing fallback audio", e);
        }
    }

    private void stopAlarm() {
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
            mediaPlayer.stop();
            mediaPlayer.release();
        }

        // Stop service
        Intent serviceIntent = new Intent(this, AlarmService.class);
        stopService(serviceIntent);
    }
}
