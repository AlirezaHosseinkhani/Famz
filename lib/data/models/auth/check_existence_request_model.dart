// lib/data/models/auth/check_existence_request_model.dart
class CheckExistenceRequestModel {
  final String email;

  const CheckExistenceRequestModel({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}
