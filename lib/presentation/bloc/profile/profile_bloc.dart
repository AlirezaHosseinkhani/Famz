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
  }) : super(const ProfileInitial()) {
    on<GetProfileEvent>(_onGetProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<PatchProfileEvent>(_onPatchProfile);
    on<ResetProfileEvent>(_onResetProfile);
  }

  Future<void> _onGetProfile(
    GetProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await getProfileUseCase();

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentProfile = (state as ProfileLoaded).profile;
      emit(ProfileUpdating(currentProfile: currentProfile));

      final params = UpdateProfileParams(
        phoneNumber: event.phoneNumber,
        bio: event.bio,
        profilePicture: event.profilePicture,
      );

      final result = await updateProfileUseCase(params);

      result.fold(
        (failure) => emit(ProfileError(message: failure.message)),
        (profile) => emit(ProfileUpdated(profile: profile)),
      );
    }
  }

  Future<void> _onPatchProfile(
    PatchProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentProfile = (state as ProfileLoaded).profile;
      emit(ProfileUpdating(currentProfile: currentProfile));

      final params = PatchProfileParams(
        phoneNumber: event.phoneNumber,
        bio: event.bio,
        profilePicture: event.profilePicture,
      );

      final result = await patchProfileUseCase(params);

      result.fold(
        (failure) => emit(ProfileError(message: failure.message)),
        (profile) => emit(ProfileUpdated(profile: profile)),
      );
    }
  }

  void _onResetProfile(
    ResetProfileEvent event,
    Emitter<ProfileState> emit,
  ) {
    emit(const ProfileInitial());
  }
}
