import 'package:flutter/foundation.dart';

class AppConfig {
  static const bool isDebug = kDebugMode;
  static const bool enableLogging = true;
  static const bool enableCrashlytics = !kDebugMode;

  // API Configuration
  static const String baseUrl = 'https://api.famz.app/v1';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Security
  static const bool enableSSLPinning = true;
  static const bool enableCertificateTransparency = true;

  // Features
  static const bool enableBiometricAuth = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = !kDebugMode;

  // Media
  static const int maxAudioDuration = 300; // 5 minutes
  static const int maxVideoDuration = 180; // 3 minutes
  static const double audioQuality = 0.8;
  static const double videoQuality = 0.8;

  // Storage
  static const int cacheSize = 100 * 1024 * 1024; // 100MB
  static const Duration cacheExpiry = Duration(days: 7);
}
