import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';

class SharedPreferencesHelper {
  final SharedPreferences _prefs;

  SharedPreferencesHelper(this._prefs);

  // User data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs.setString(StorageKeys.userData, json.encode(userData));
  }

  Map<String, dynamic>? getUserData() {
    final userData = _prefs.getString(StorageKeys.userData);
    if (userData != null) {
      return json.decode(userData) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> clearUserData() async {
    await _prefs.remove(StorageKeys.userData);
  }

  // Login status
  Future<void> setLoggedIn(bool isLoggedIn) async {
    await _prefs.setBool(StorageKeys.isLoggedIn, isLoggedIn);
  }

  bool isLoggedIn() {
    return _prefs.getBool(StorageKeys.isLoggedIn) ?? false;
  }

  // First launch
  Future<void> setFirstLaunch(bool isFirstLaunch) async {
    await _prefs.setBool(StorageKeys.isFirstLaunch, isFirstLaunch);
  }

  bool isFirstLaunch() {
    return _prefs.getBool(StorageKeys.isFirstLaunch) ?? true;
  }

  // Notification permission
  Future<void> setNotificationPermission(bool granted) async {
    await _prefs.setBool(StorageKeys.notificationPermission, granted);
  }

  bool getNotificationPermission() {
    return _prefs.getBool(StorageKeys.notificationPermission) ?? false;
  }

  // Language
  Future<void> setLanguageCode(String languageCode) async {
    await _prefs.setString(StorageKeys.languageCode, languageCode);
  }

  String? getLanguageCode() {
    return _prefs.getString(StorageKeys.languageCode);
  }

  // Theme
  Future<void> setThemeMode(String themeMode) async {
    await _prefs.setString(StorageKeys.themeMode, themeMode);
  }

  String? getThemeMode() {
    return _prefs.getString(StorageKeys.themeMode);
  }

  // Clear all preferences
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
