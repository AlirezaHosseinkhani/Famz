import '../../../domain/entities/to_user.dart';

class ToUserModel {
  final int id;
  final String email;
  final String username;
  final String? phoneNumber;
  final String? profilePicture;
  final String? bio;

  ToUserModel({
    required this.id,
    required this.email,
    required this.username,
    this.phoneNumber,
    this.profilePicture,
    this.bio,
  });

  factory ToUserModel.fromJson(Map<String, dynamic> json) {
    return ToUserModel(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      phoneNumber: json['phone_number'],
      profilePicture: json['profile_picture'],
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'phone_number': phoneNumber,
      'profile_picture': profilePicture,
      'bio': bio,
    };
  }

  ToUser toEntity() {
    return ToUser(
      id: id,
      email: email,
      username: username,
      phoneNumber: phoneNumber,
      profilePicture: profilePicture,
      bio: bio,
    );
  }
}
