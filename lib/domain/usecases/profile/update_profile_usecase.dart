import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/profile.dart';
import '../../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, Profile>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(
      phoneNumber: params.phoneNumber,
      bio: params.bio,
      profilePicture: params.profilePicture,
    );
  }
}

class UpdateProfileParams {
  final String? phoneNumber;
  final String? bio;
  final String? profilePicture;

  UpdateProfileParams({
    this.phoneNumber,
    this.bio,
    this.profilePicture,
  });
}
