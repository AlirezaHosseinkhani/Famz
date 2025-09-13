import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'app.dart';
import 'core/services/firebase_messaging_service.dart';
import 'core/services/notification_service.dart';
import 'injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  // Initialize Firebase
  await Firebase.initializeApp();
  // If you used flutterfire configure, replace with:
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize DI
  await di.init();

  // Initialize local notifications
  await NotificationService().init();

  // Initialize Firebase Messaging (permissions, token, listeners)
  await FirebaseMessagingService().init();

  // Lock orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const FamzApp());
}
