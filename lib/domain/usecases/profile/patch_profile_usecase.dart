import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/profile.dart';
import '../../repositories/profile_repository.dart';

class PatchProfileUseCase {
  final ProfileRepository repository;

  PatchProfileUseCase(this.repository);

  Future<Either<Failure, Profile>> call(PatchProfileParams params) async {
    return await repository.patchProfile(
      phoneNumber: params.phoneNumber,
      bio: params.bio,
      profilePicture: params.profilePicture,
    );
  }
}

class PatchProfileParams {
  final String? phoneNumber;
  final String? bio;
  final String? profilePicture;

  PatchProfileParams({
    this.phoneNumber,
    this.bio,
    this.profilePicture,
  });
}
