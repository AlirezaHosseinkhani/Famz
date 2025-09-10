// lib/data/models/auth/login_request_model.dart
class LoginRequestModel {
  final String emailOrPhone;
  final String password;

  const LoginRequestModel({
    required this.emailOrPhone,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone_number': emailOrPhone,
      'password': password,
    };
  }
}
