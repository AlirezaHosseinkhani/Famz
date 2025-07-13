import 'package:equatable/equatable.dart';

import '../../../domain/entities/profile.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final Profile profile;

  const ProfileLoaded({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdating extends ProfileState {
  final Profile currentProfile;

  const ProfileUpdating({required this.currentProfile});

  @override
  List<Object?> get props => [currentProfile];
}

class ProfileUpdated extends ProfileState {
  final Profile profile;

  const ProfileUpdated({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}
