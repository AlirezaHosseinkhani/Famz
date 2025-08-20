import 'package:shared_preferences/shared_preferences.dart';

class DevConfigService {
  static const String _ipAddressKey = 'dev_ip_address';
  static const String _defaultIp = '164.90.178.164:8000';

  static Future<String> getIpAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ipAddressKey) ?? _defaultIp;
  }

  static Future<void> setIpAddress(String ipAddress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ipAddressKey, ipAddress);
  }

  static Future<void> clearIpAddress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ipAddressKey);
  }
}
