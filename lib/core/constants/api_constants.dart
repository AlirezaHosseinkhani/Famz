class ApiConstants {
  static const String baseUrl = 'http://192.168.0.188:8000/api';
  static const String apiVersion = '/api';

  // static const String baseUrl = 'https://api.famz.app/v1';
  static const String authEndpoint = '/auth';
  static const String profileEndpoint = '/profile';
  static const String alarmsEndpoint = '/alarms';
  static const String requestsEndpoint = '/requests';
  static const String recordingsEndpoint = '/recordings';
  static const String notificationsEndpoint = '/notifications';

  // Auth endpoints
  static const String loginEndpoint = '$apiVersion/$authEndpoint/login/';
  static const String registerEndpoint = '$apiVersion/$authEndpoint/register';
  static const String verifyPhoneEndpoint =
      '$apiVersion/$authEndpoint/verify-phone';
  static const String verifyOtpEndpoint =
      '$apiVersion/$authEndpoint/verify-otp';
  static const String refreshTokenEndpoint =
      '$apiVersion/$authEndpoint/refresh';
  static const String logoutEndpoint = '$apiVersion/$authEndpoint/logout';

  // Alarm recording endpoints
  static const String sentRequests = '$apiVersion/sent-requests/';
  static const String receivedRequests = '$apiVersion/received-requests/';
  static const String alarmRecordings = '$apiVersion/alarm-recordings/';

  // Notification endpoints
  static const String notifications = '$apiVersion/notifications/';
  static const String markAllAsRead =
      '$apiVersion/notifications/mark_all_as_read/';

  // // Headers
  // static const Map<String, String> headers = {
  //   'Content-Type': 'application/json',
  //   'Accept': 'application/json',
  // };
  //
  // static Map<String, String> authHeaders(String token) => {
  //       ...headers,
  //       'Authorization': 'Bearer $token',
  //     };

  // Headers
  static const String contentType = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;
}
