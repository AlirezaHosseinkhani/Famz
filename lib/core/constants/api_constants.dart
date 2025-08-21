class ApiConstants {
  static String? _cachedBaseUrl;

  // static Future<String> get baseUrl async {
  //   // if (_cachedBaseUrl == null) {
  //   //   final ip = await DevConfigService.getIpAddress();
  //   //   _cachedBaseUrl = 'http://$ip';
  //   // }
  //   // return _cachedBaseUrl!;
  //   return _cachedBaseUrl!;
  // }

  // Call this when IP changes to refresh the cached URL
  static void refreshBaseUrl() {
    _cachedBaseUrl = null;
  }

  static const String baseUrl = 'http://164.90.178.164:8000';
  static const String apiVersion = 'api';

  // static const String baseUrl = 'https://api.famz.app/v1';
  static const String authEndpoint = 'auth';
  static const String profileEndpoint = '/$apiVersion/profile/';
  static const String alarmsEndpoint = '/$apiVersion/alarm-recordings';
  static const String requestsEndpoint = '/$apiVersion/requests';
  static const String recordingsEndpoint = '/$apiVersion/recordings';
  static const String notificationsEndpoint = '/$apiVersion/notifications';

  // Auth endpoints
  static const String loginEndpoint = '/$apiVersion/$authEndpoint/login/';
  static const String registerEndpoint = '/$apiVersion/$authEndpoint/register/';
  static const String verifyPhoneEndpoint =
      '$apiVersion/$authEndpoint/verify-phone';
  static const String verifyOtpEndpoint =
      '$apiVersion/$authEndpoint/verify-otp';
  static const String refreshTokenEndpoint =
      '$apiVersion/$authEndpoint/refresh';
  static const String validateTokenEndpoint = '/api/auth/token/refresh/';
  static const String checkExistenceEndpoint = '/api/check-existence/';

  static const String logoutEndpoint = '$apiVersion/$authEndpoint/logout';

  // Alarm recording endpoints
  static const String sentRequests = '$apiVersion/sent-requests/';
  static const String receivedRequests = '$apiVersion/received-requests/';
  static const String alarmRecordings = '$apiVersion/alarm-recordings/';

  static const String alarmRecordingsEndpoint =
      '/$apiVersion/alarm-recordings/';

  // Notification endpoints
  static const String notifications = '$apiVersion/notifications/';
  static const String markAllAsRead =
      '/$apiVersion/notifications/mark_all_as_read/';

  static const String sentRequestsEndpoint = '/api/sent-requests/';
  static const String receivedRequestsEndpoint = '/api/received-requests/';

  // Headers
  static const String contentType = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;
}
