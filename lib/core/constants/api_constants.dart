class ApiConstants {
  // static const String baseUrl = 'http://192.168.0.142:8000';
  static const String baseUrl = 'http://192.168.28.23:8000';
  static const String apiVersion = 'api';

  // static const String baseUrl = 'https://api.famz.app/v1';
  static const String authEndpoint = 'auth';
  static const String profileEndpoint = '/$apiVersion/profile';
  static const String alarmsEndpoint = '/$apiVersion/alarm-recordings';
  static const String requestsEndpoint = '/$apiVersion/requests';
  static const String recordingsEndpoint = '/$apiVersion/recordings';
  static const String notificationsEndpoint = '/$apiVersion/notifications';

  // Auth endpoints
  static const String loginEndpoint = '/$apiVersion/$authEndpoint/login/';
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

  static const String alarmRecordingsEndpoint =
      '/$apiVersion/alarm-recordings/';

  // Notification endpoints
  static const String notifications = '$apiVersion/notifications/';
  static const String markAllAsRead =
      '$apiVersion/notifications/mark_all_as_read/';

  static const String sentRequestsEndpoint = '/api/sent-requests';
  static const String receivedRequestsEndpoint = '/api/received-requests';

  // Headers
  static const String contentType = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;
}

// class ApiConstants {
//   static const String baseUrl = 'http://192.168.0.188:8000';
//   static const String apiVersion = '/api';
//
//   // static const String baseUrl = 'https://api.famz.app/v1';
//   static const String authEndpoint = 'auth';
//   static const String profileEndpoint = '$apiVersion/profile';
//   static const String alarmsEndpoint = '$apiVersion/alarms';
//   static const String requestsEndpoint = '$apiVersion/requests';
//   static const String recordingsEndpoint = '$apiVersion/recordings';
//   static const String notificationsEndpoint = '$apiVersion/notifications';
//
//   // Auth endpoints
//   static const String loginEndpoint = '$apiVersion/$authEndpoint/login/';
//
//   // static const String loginEndpoint = '$apiVersion/auth/login/';
//   static const String registerEndpoint = '$apiVersion/auth/register/';
//   static const String refreshTokenEndpoint = '$apiVersion/auth/token/refresh/';
//
//   static const String verifyPhoneEndpoint =
//       '$apiVersion/$authEndpoint/verify-phone';
//   static const String verifyOtpEndpoint =
//       '$apiVersion/$authEndpoint/verify-otp';
//
//   static const String logoutEndpoint = '$apiVersion/$authEndpoint/logout';
//
//   // Alarm recording endpoints
//   static const String sentRequestsEndpoint = '$apiVersion/alarm-recordings/';
//   static const String receivedRequestsEndpoint = '$apiVersion/sent-requests/';
//   static const String alarmRecordingsEndpoint =
//       '$apiVersion/received-requests/';
//
//   // Notification endpoints
//   // static const String notificationsEndpoint = '$apiVersion/notifications/';
//   static const String markAllAsReadEndpoint =
//       '$apiVersion/notifications/mark_all_as_read/';
//
//   // Profile endpoints
//   // static const String profileEndpoint = '$apiVersion/profile/';
//
//   // Headers
//   static const String contentType = 'application/json';
//   static const String authorization = 'Authorization';
//   static const String bearer = 'Bearer';
//
//   // Timeouts
//   static const int connectTimeout = 30000;
//   static const int receiveTimeout = 30000;
//   static const int sendTimeout = 30000;
// }
