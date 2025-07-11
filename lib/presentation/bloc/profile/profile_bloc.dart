// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:injectable/injectable.dart';
//
// import '../../../core/errors/failures.dart';
// import '../../../domain/entities/profile.dart';
// import '../../../domain/usecases/profile/get_profile_usecase.dart';
// import '../../../domain/usecases/profile/patch_profile_usecase.dart';
// import '../../../domain/usecases/profile/update_profile_usecase.dart';
// import 'profile_event.dart';
// import 'profile_state.dart';
//
// @injectable
// class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
//   final GetProfileUseCase _getProfileUseCase;
//   final UpdateProfileUseCase _updateProfileUseCase;
//   final PatchProfileUseCase _patchProfileUseCase;
//
//   ProfileBloc({
//     required GetProfileUseCase getProfileUseCase,
//     required UpdateProfileUseCase updateProfileUseCase,
//     required PatchProfileUseCase patchProfileUseCase,
//   })  : _getProfileUseCase = getProfileUseCase,
//         _updateProfileUseCase = updateProfileUseCase,
//         _patchProfileUseCase = patchProfileUseCase,
//         super(const ProfileInitial()) {
//     on<GetProfileRequested>(_onGetProfileRequested);
//     on<UpdateProfileRequested>(_onUpdateProfileRequested);
//     on<PatchProfileRequested>(_onPatchProfileRequested);
//     on<UpdateProfilePictureRequested>(_onUpdateProfilePictureRequested);
//   }
//
//   Future<void> _onGetProfileRequested(
//     GetProfileRequested event,
//     Emitter<ProfileState> emit,
//   ) async {
//     emit(const ProfileLoading());
//
//     final result = await _getProfileUseCase.call();
//
//     result.fold(
//       (failure) => emit(ProfileError(
//         failure: failure,
//         message: _mapFailureToMessage(failure),
//       )),
//       (profile) => emit(ProfileLoaded(profile: profile)),
//     );
//   }
//
//   Future<void> _onUpdateProfileRequested(
//     UpdateProfileRequested event,
//     Emitter<ProfileState> emit,
//   ) async {
//     final currentState = state;
//     if (currentState is ProfileLoaded) {
//       emit(ProfileUpdating(currentProfile: currentState.profile));
//     } else {
//       emit(const ProfileLoading());
//     }
//
//     final result = await _updateProfileUseCase.call(
//       UpdateProfileParams(profile: event.profile),
//     );
//
//     result.fold(
//       (failure) => emit(ProfileError(
//         failure: failure,
//         message: _mapFailureToMessage(failure),
//       )),
//       (updatedProfile) => emit(ProfileUpdateSuccess(
//         profile: updatedProfile,
//         message: 'Profile updated successfully',
//       )),
//     );
//   }
//
//   Future<void> _onPatchProfileRequested(
//     PatchProfileRequested event,
//     Emitter<ProfileState> emit,
//   ) async {
//     final currentState = state;
//     if (currentState is ProfileLoaded) {
//       emit(ProfileUpdating(currentProfile: currentState.profile));
//     } else {
//       emit(const ProfileLoading());
//     }
//
//     final result = await _patchProfileUseCase.call(
//       PatchProfileParams(updates: event.updates),
//     );
//
//     result.fold(
//       (failure) => emit(ProfileError(
//         failure: failure,
//         message: _mapFailureToMessage(failure),
//       )),
//       (updatedProfile) => emit(ProfileUpdateSuccess(
//         profile: updatedProfile,
//         message: 'Profile updated successfully',
//       )),
//     );
//   }
//
//   Future<void> _onUpdateProfilePictureRequested(
//     UpdateProfilePictureRequested event,
//     Emitter<ProfileState> emit,
//   ) async {
//     final currentState = state;
//     if (currentState is ProfileLoaded) {
//       emit(ProfileUpdating(currentProfile: currentState.profile));
//     } else {
//       emit(const ProfileLoading());
//     }
//
//     final result = await _patchProfileUseCase.call(
//       PatchProfileParams(updates: {'profile_picture': event.profilePicture}),
//     );
//
//     result.fold(
//       (failure) => emit(ProfileError(
//         failure: failure,
//         message: _mapFailureToMessage(failure),
//       )),
//       (updatedProfile) => emit(ProfileUpdateSuccess(
//         profile: updatedProfile,
//         message: 'Profile picture updated successfully',
//       )),
//     );
//   }
//
//   String _mapFailureToMessage(Failure failure) {
//     switch (failure.runtimeType) {
//       case ServerFailure:
//         return 'Server error occurred. Please try again.';
//       case CacheFailure:
//         return 'Cache error occurred. Please try again.';
//       case NetworkFailure:
//         return 'Network error. Please check your connection.';
//       default:
//         return 'An unexpected error occurred.';
//     }
//   }
// }

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/profile/get_profile_usecase.dart';
import '../../../domain/usecases/profile/patch_profile_usecase.dart';
import '../../../domain/usecases/profile/update_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final PatchProfileUseCase patchProfileUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.patchProfileUseCase,
  }) : super(ProfileInitial()) {
    on<GetProfileEvent>(_onGetProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<PatchProfileEvent>(_onPatchProfile);
  }

  Future<void> _onGetProfile(
    GetProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final result = await getProfileUseCase();

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileUpdating());

    final params = UpdateProfileParams(
      phoneNumber: event.phoneNumber,
      bio: event.bio,
      profilePicture: event.profilePicture,
    );

    final result = await updateProfileUseCase(params);

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileUpdated(profile)),
    );
  }

  Future<void> _onPatchProfile(
    PatchProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileUpdating());

    final params = PatchProfileParams(
      phoneNumber: event.phoneNumber,
      bio: event.bio,
      profilePicture: event.profilePicture,
    );

    final result = await patchProfileUseCase(params);

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileUpdated(profile)),
    );
  }
}
