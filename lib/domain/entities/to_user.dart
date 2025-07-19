import 'package:equatable/equatable.dart';

class ToUser extends Equatable {
  final int id;
  final String email;
  final String username;
  final String? phoneNumber;
  final String? profilePicture;
  final String? bio;

  const ToUser({
    required this.id,
    required this.email,
    required this.username,
    this.phoneNumber,
    this.profilePicture,
    this.bio,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        phoneNumber,
        profilePicture,
        bio,
      ];
}
