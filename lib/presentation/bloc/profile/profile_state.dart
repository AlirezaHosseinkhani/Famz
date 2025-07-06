// import 'package:equatable/equatable.dart';
//
// import '../../../core/errors/failures.dart';
// import '../../../domain/entities/profile.dart';
//
// abstract class ProfileState extends Equatable {
//   const ProfileState();
//
//   @override
//   List<Object?> get props => [];
// }
//
// class ProfileInitial extends ProfileState {
//   const ProfileInitial();
// }
//
// class ProfileLoading extends ProfileState {
//   const ProfileLoading();
// }
//
// class ProfileLoaded extends ProfileState {
//   final Profile profile;
//
//   const ProfileLoaded({required this.profile});
//
//   @override
//   List<Object?> get props => [profile];
//
//   ProfileLoaded copyWith({Profile? profile}) {
//     return ProfileLoaded(profile: profile ?? this.profile);
//   }
// }
//
// class ProfileError extends ProfileState {
//   final Failure failure;
//   final String message;
//
//   const ProfileError({
//     required this.failure,
//     required this.message,
//   });
//
//   @override
//   List<Object?> get props => [failure, message];
// }
//
// class ProfileUpdateSuccess extends ProfileState {
//   final Profile profile;
//   final String message;
//
//   const ProfileUpdateSuccess({
//     required this.profile,
//     required this.message,
//   });
//
//   @override
//   List<Object?> get props => [profile, message];
// }
//
// class ProfileUpdating extends ProfileState {
//   final Profile currentProfile;
//
//   const ProfileUpdating({required this.currentProfile});
//
//   @override
//   List<Object?> get props => [currentProfile];
// }
import 'package:equatable/equatable.dart';

import '../../../domain/entities/profile.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Profile profile;

  const ProfileLoaded({required this.profile});

  @override
  List<Object> get props => [profile];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object> get props => [message];
}

class ProfileUpdated extends ProfileState {
  final Profile profile;

  const ProfileUpdated({required this.profile});

  @override
  List<Object> get props => [profile];
}
