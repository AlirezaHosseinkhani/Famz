import '../../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required int id,
    required String email,
    required String username,
    String? phoneNumber,
    bool? isActive,
    DateTime? dateJoined,
  }) : super(
          id: id,
          email: email,
          username: username,
          phoneNumber: phoneNumber,
          isActive: isActive,
          dateJoined: dateJoined,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      // Changed to int to match User entity
      email: json['email']?.toString() ?? '',
      // Made required
      username: json['username']?.toString() ?? '',
      // Made required
      phoneNumber: json['phone_number']?.toString(),
      isActive: json['is_active'] as bool?,
      dateJoined: json['date_joined'] != null
          ? DateTime.parse(json['date_joined'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'phone_number': phoneNumber,
      'is_active': isActive,
      'date_joined': dateJoined?.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      username: user.username,
      phoneNumber: user.phoneNumber,
      isActive: user.isActive,
      dateJoined: user.dateJoined,
    );
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      username: username,
      phoneNumber: phoneNumber,
      isActive: isActive,
      dateJoined: dateJoined,
    );
  }
}
