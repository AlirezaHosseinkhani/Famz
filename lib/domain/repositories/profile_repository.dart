import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, Profile>> getProfile();

  Future<Either<Failure, Profile>> updateProfile({
    String? phoneNumber,
    String? bio,
    String? profilePicture,
  });

  Future<Either<Failure, Profile>> patchProfile({
    String? phoneNumber,
    String? bio,
    String? profilePicture,
  });
}
