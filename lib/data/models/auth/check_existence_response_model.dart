// lib/data/models/auth/check_existence_response_model.dart
class CheckExistenceResponseModel {
  final bool exists;
  final String? message;

  const CheckExistenceResponseModel({
    required this.exists,
    this.message,
  });

  factory CheckExistenceResponseModel.fromJson(Map<String, dynamic> json) {
    return CheckExistenceResponseModel(
      exists: json['exists'] as bool,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exists': exists,
      if (message != null) 'message': message,
    };
  }
}
