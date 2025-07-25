import 'package:famz/presentation/pages/main/alarms/set_alarm_page.dart';
import 'package:flutter/material.dart';

import '../pages/auth/intro_page.dart';
import '../pages/auth/name_input_page.dart';
import '../pages/auth/notification_permission_page.dart';
import '../pages/auth/otp_verification_page.dart';
import '../pages/auth/phone_verification_page.dart';
// import '../pages/main/alarms/alarm_details_page.dart';
// import '../pages/main/alarms/set_alarm_page.dart';
import '../pages/main/main_page.dart';
import '../pages/main/notifications/notifications_page.dart';
// import '../pages/main/profile/edit_profile_page.dart';
import '../pages/main/profile/profile_page.dart';
import '../pages/main/requests/requests_page.dart';
// import '../pages/main/requests/record_alarm_page.dart';
// import '../pages/main/requests/share_request_page.dart';
// import '../pages/recording/audio_recording_page.dart';
// import '../pages/recording/video_recording_page.dart';
import '../pages/splash/splash_page.dart';
import 'route_names.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
          settings: settings,
        );

      case RouteNames.intro:
        return MaterialPageRoute(
          builder: (_) => const IntroPage(),
          settings: settings,
        );

      case RouteNames.phoneVerification:
        return MaterialPageRoute(
          builder: (_) => const PhoneVerificationPage(),
          settings: settings,
        );

      case RouteNames.otpVerification:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => OtpVerificationPage(
            phoneNumber: args?['phoneNumber'] ?? '',
            isNewUser: args?['isNewUser'] ?? false,
          ),
          settings: settings,
        );

      case RouteNames.nameInput:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => NameInputPage(
            phoneNumber: args?['phoneNumber'] ?? '',
            otpCode: args?['otpCode'] ?? '',
          ),
          settings: settings,
        );

      case RouteNames.notificationPermission:
        return MaterialPageRoute(
          builder: (_) => const NotificationPermissionPage(),
          settings: settings,
        );

      case RouteNames.main:
        return MaterialPageRoute(
          builder: (_) => const MainPage(),
          settings: settings,
        );

      case RouteNames.notification:
        return MaterialPageRoute(
          builder: (_) => const NotificationsPage(),
          settings: settings,
        );

      case RouteNames.request:
        return MaterialPageRoute(
          builder: (_) => const RequestsPage(),
          settings: settings,
        );

      // case RouteNames.setAlarm:
      //   final alarm = settings.arguments as Alarm?;
      //   return MaterialPageRoute(
      //     builder: (_) => BlocProvider<AlarmBloc>(
      //       create: (_) => di.sl<AlarmBloc>(),
      //       child: SetAlarmPage(alarm: alarm),
      //     ),
      //   );

      case RouteNames.setAlarm:
        return MaterialPageRoute(
          builder: (_) => const SetAlarmPage(),
          settings: settings,
        );
      //
      // case RouteNames.alarmDetails:
      //   final args = settings.arguments as Map<String, dynamic>?;
      //   return MaterialPageRoute(
      //     builder: (_) => AlarmDetailsPage(
      //       alarmId: args?['alarmId'] ?? '',
      //     ),
      //     settings: settings,
      //   );
      //
      // case RouteNames.recordAlarm:
      //   final args = settings.arguments as Map<String, dynamic>?;
      //   return MaterialPageRoute(
      //     builder: (_) => RecordAlarmPage(
      //       requestId: args?['requestId'] ?? '',
      //       recordingType: args?['recordingType'] ?? 'audio',
      //     ),
      //     settings: settings,
      //   );
      //
      // case RouteNames.shareRequest:
      //   return MaterialPageRoute(
      //     builder: (_) => const ShareRequestPage(),
      //     settings: settings,
      //   );

      case RouteNames.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
          settings: settings,
        );

      // case RouteNames.editProfile:
      //   return MaterialPageRoute(
      //     builder: (_) => const EditProfilePage(),
      //     settings: settings,
      //   );

      // case RouteNames.audioRecording:
      //   final args = settings.arguments as Map<String, dynamic>?;
      //   return MaterialPageRoute(
      //     builder: (_) => AudioRecordingPage(
      //       requestId: args?['requestId'] ?? '',
      //     ),
      //     settings: settings,
      //   );

      // case RouteNames.videoRecording:
      //   final args = settings.arguments as Map<String, dynamic>?;
      //   return MaterialPageRoute(
      //     builder: (_) => VideoRecordingPage(
      //       requestId: args?['requestId'] ?? '',
      //     ),
      //     settings: settings,
      //   );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
