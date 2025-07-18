import '../../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.email,
    required super.username,
    super.phoneNumber,
    super.bio,
    super.profilePicture,
    // required super.createdAt,
    // required super.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as int,
      email: json['email'] as String,
      username: json['username'] as String,
      phoneNumber: json['phone_number'] as String?,
      bio: json['bio'] as String?,
      profilePicture: json['profile_picture'] as String?,
      // createdAt: DateTime.parse(json['created_at'] as String),
      // updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'phone_number': phoneNumber,
      'bio': bio,
      'profile_picture': profilePicture,
      // 'created_at': createdAt.toIso8601String(),
      // 'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ProfileModel.fromEntity(Profile profile) {
    return ProfileModel(
      id: profile.id,
      email: profile.email,
      username: profile.username,
      phoneNumber: profile.phoneNumber,
      bio: profile.bio,
      profilePicture: profile.profilePicture,
      // createdAt: profile.createdAt,
      // updatedAt: profile.updatedAt,
    );
  }
}
