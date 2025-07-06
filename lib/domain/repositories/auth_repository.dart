import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> sendVerificationCode(String phoneNumber);

  Future<Either<Failure, User>> verifyOtpAndLogin(
      String phoneNumber, String otpCode);

  Future<Either<Failure, User>> login(String phoneNumber, String password);

  Future<Either<Failure, User>> register(
      String phoneNumber, String name, String otpCode);

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User>> refreshToken();

  Future<Either<Failure, User?>> getCurrentUser();

  Future<Either<Failure, bool>> isLoggedIn();
}
