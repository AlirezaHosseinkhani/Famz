import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  // System Alert Window Permission Methods
  static Future<bool> isSystemAlertWindowGranted() async {
    final status = await Permission.systemAlertWindow.status;
    return status.isGranted;
  }

  static Future<bool> shouldRequestSystemAlertWindow() async {
    final status = await Permission.systemAlertWindow.status;
    return status.isDenied || status.isPermanentlyDenied;
  }

  // Notification Permission Methods
  static Future<bool> isNotificationGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  static Future<bool> shouldRequestNotification() async {
    final status = await Permission.notification.status;
    return status.isDenied || status.isPermanentlyDenied;
  }

  // Combined Permission Check Methods
  static Future<bool> areAllPermissionsGranted() async {
    final systemAlertGranted = await isSystemAlertWindowGranted();
    final notificationGranted = await isNotificationGranted();
    return systemAlertGranted && notificationGranted;
  }

  static Future<PermissionNavigationType>
      getRequiredPermissionNavigation() async {
    final systemAlertGranted = await isSystemAlertWindowGranted();
    final notificationGranted = await isNotificationGranted();

    if (systemAlertGranted && notificationGranted) {
      return PermissionNavigationType.mainScreen;
    } else if (!systemAlertGranted) {
      return PermissionNavigationType.systemAlertWindow;
    } else {
      return PermissionNavigationType.notification;
    }
  }
}

enum PermissionNavigationType {
  systemAlertWindow,
  notification,
  mainScreen,
}
