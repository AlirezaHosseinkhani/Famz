class AppConstants {
  static const String appName = 'Famz';
  static const String appVersion = '1.0.0';

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String notificationPermissionKey = 'notification_permission';

  // Notification channels
  static const String alarmChannelId = 'alarm_channel';
  static const String alarmChannelName = 'Alarm Notifications';
  static const String alarmChannelDescription = 'Notifications for alarms';

  // File upload
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  static const List<String> allowedAudioFormats = ['mp3', 'wav', 'aac', 'm4a'];
  static const List<String> allowedVideoFormats = ['mp4', 'mov', 'avi'];

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // Sizes
  static const double borderRadius = 12.0;
  static const double padding = 16.0;
  static const double margin = 8.0;

  // Audio/Video limits
  static const int maxRecordingDuration = 60; // 1 minutes in seconds
  static const int minRecordingDuration = 1; // 1 second

  // Validation
  static const int phoneNumberLength = 11;
  static const int otpLength = 6;
  static const int nameMinLength = 2;
  static const int nameMaxLength = 50;
}
