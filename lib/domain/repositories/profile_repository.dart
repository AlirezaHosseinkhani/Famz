import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, Profile>> getProfile();

  Future<Either<Failure, Profile>> patchProfile();

  Future<Either<Failure, Profile>> updateProfile();

  // Future<Either<Failure, User>> register(
  //     String phoneNumber, String name, String otpCode);
  //
  // Future<Either<Failure, void>> logout();
  //
  // Future<Either<Failure, User>> refreshToken();
  //
  // Future<Either<Failure, User?>> getCurrentUser();
  //
  // Future<Either<Failure, bool>> isLoggedIn();
}
