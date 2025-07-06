import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final int id;
  final String email;
  final String username;
  final String? phoneNumber;
  final String? bio;
  final String? profilePicture;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.id,
    required this.email,
    required this.username,
    this.phoneNumber,
    this.bio,
    this.profilePicture,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        phoneNumber,
        bio,
        profilePicture,
        createdAt,
        updatedAt,
      ];
}
