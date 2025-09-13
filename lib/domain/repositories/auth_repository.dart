// lib/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../data/models/auth/check_existence_response_model.dart';
import '../../data/models/auth/token_model.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, CheckExistenceResponseModel>> checkExistence(
      String emailOrPhone);

  Future<Either<Failure, TokenModel>> login(
      String emailOrPhone, String password);

  Future<Either<Failure, TokenModel>> register(
      String emailOrPhone, String password, String username);

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, TokenModel>> refreshToken(String refreshToken);

  Future<Either<Failure, User?>> getCurrentUser();

  Future<Either<Failure, bool>> isLoggedIn();

  Future<Either<Failure, void>> updateFcmToken(String fcmToken);
}
