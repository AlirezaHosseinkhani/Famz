import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> isSystemAlertWindowGranted() async {
    final status = await Permission.systemAlertWindow.status;
    return status.isGranted;
  }

  static Future<bool> shouldRequestSystemAlertWindow() async {
    final status = await Permission.systemAlertWindow.status;
    return status.isDenied || status.isPermanentlyDenied;
  }
}
