import 'package:firebase_messaging/firebase_messaging.dart';

import 'notification_service.dart';

// Background message handler must be a top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
// Ensure Firebase is initialized in background isolate
  try {
// Importing firebase_core and calling initialize might be necessary depending on your setup.
// await Firebase.initializeApp(); // uncomment if needed
  } catch (_) {}

// Initialize local notification plugin in background if required
  await NotificationService().init();
  await NotificationService().showLocalNotificationFromRemoteMessage(message);
}

class FirebaseMessagingService {
  final FirebaseMessaging _fm = FirebaseMessaging.instance;

  Future<void> init() async {
// Request permissions (iOS) — for Android 13+ you'll still need POST_NOTIFICATIONS permission in Manifest and request at runtime.
    final settings = await _fm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);
// Print permission status
    print('FCM permission status: ${settings.authorizationStatus}');

// Get token
    final token = await _fm.getToken();
    print('FCM token: $token');
// TODO: send this token to your server if needed

// Background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

// Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
// Show local notification
      await NotificationService()
          .showLocalNotificationFromRemoteMessage(message);
// Optionally dispatch to NotificationBloc or other state management
    });

// App opened from background via notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
// handle navigation / state changes
      print('onMessageOpenedApp: ${message.data}');
    });

// Handle initial message when app was terminated
    final initialMessage = await _fm.getInitialMessage();
    if (initialMessage != null) {
      print('Initial message: ${initialMessage.data}');
// handle navigation
    }
  }
}
