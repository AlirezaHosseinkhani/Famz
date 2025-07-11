// import 'package:equatable/equatable.dart';
//
// import '../../../domain/entities/profile.dart';
//
// abstract class ProfileEvent extends Equatable {
//   const ProfileEvent();
//
//   @override
//   List<Object?> get props => [];
// }
//
// class GetProfileRequested extends ProfileEvent {
//   const GetProfileRequested();
// }
//
// class UpdateProfileRequested extends ProfileEvent {
//   final Profile profile;
//
//   const UpdateProfileRequested({required this.profile});
//
//   @override
//   List<Object?> get props => [profile];
// }
//
// class PatchProfileRequested extends ProfileEvent {
//   final Map<String, dynamic> updates;
//
//   const PatchProfileRequested({required this.updates});
//
//   @override
//   List<Object?> get props => [updates];
// }
//
// class UpdateProfilePictureRequested extends ProfileEvent {
//   final String profilePicture;
//
//   const UpdateProfilePictureRequested({required this.profilePicture});
//
//   @override
//   List<Object?> get props => [profilePicture];
// }

import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class GetProfileEvent extends ProfileEvent {}

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
