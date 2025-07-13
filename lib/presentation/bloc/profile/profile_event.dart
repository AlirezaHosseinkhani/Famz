import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class GetProfileEvent extends ProfileEvent {
  const GetProfileEvent();
}

class UpdateProfileEvent extends ProfileEvent {
  final String? phoneNumber;
  final String? bio;
  final String? profilePicture;

  const UpdateProfileEvent({
    this.phoneNumber,
    this.bio,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [phoneNumber, bio, profilePicture];
}

class PatchProfileEvent extends ProfileEvent {
  final String? phoneNumber;
  final String? bio;
  final String? profilePicture;

  const PatchProfileEvent({
    this.phoneNumber,
    this.bio,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [phoneNumber, bio, profilePicture];
}

class ResetProfileEvent extends ProfileEvent {
  const ResetProfileEvent();
}
