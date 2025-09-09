// lib/data/models/auth/check_existence_request_model.dart
class CheckExistenceRequestModel {
  final String phoneNumber;

  const CheckExistenceRequestModel({
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
    };
  }
}
