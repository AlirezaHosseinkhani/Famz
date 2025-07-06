class RegisterRequestModel {
  final String phoneNumber;
  final String name;
  final String otpCode;
  final String? deviceId;
  final String? fcmToken;

  const RegisterRequestModel({
    required this.phoneNumber,
    required this.name,
    required this.otpCode,
    this.deviceId,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'name': name,
      'otp_code': otpCode,
      if (deviceId != null) 'device_id': deviceId,
      if (fcmToken != null) 'fcm_token': fcmToken,
    };
  }
}
