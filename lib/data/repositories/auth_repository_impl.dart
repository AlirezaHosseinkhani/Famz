import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../data/models/auth/token_model.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/auth/login_request_model.dart';
import '../models/auth/register_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, String>> sendVerificationCode(String email) async {
    if (await networkInfo.isConnected) {
      try {
        final request = LoginRequestModel(email: email, password: "123456");
        final response = await remoteDataSource.sendVerificationCode(request);
        return Right("Verification code sent successfully");
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message, code: e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message, code: e.code));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure('Failed to send verification code'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, User>> verifyOtpAndLogin(
      String phoneNumber, String otpCode) async {
    if (await networkInfo.isConnected) {
      try {
        final tokenResponse =
            await remoteDataSource.verifyOtpAndLogin(phoneNumber, otpCode);
        await localDataSource.saveTokens(tokenResponse);

        final userResponse = await remoteDataSource.getCurrentUser();
        await localDataSource.saveUser(userResponse);
        await localDataSource.setLoggedIn(true);

        return Right(userResponse.toEntity());
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message, code: e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message, code: e.code));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure('OTP verification failed'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, TokenModel>> login(
      String phoneNumber, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final tokenResponse =
            await remoteDataSource.login(phoneNumber, password);

        await localDataSource.saveTokens(tokenResponse);
        await localDataSource.setLoggedIn(true);

        return Right(tokenResponse);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message, code: e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message, code: e.code));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure('Login failed'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, TokenModel>> register(
      String phoneNumber, String name, String otpCode) async {
    if (await networkInfo.isConnected) {
      try {
        final request = RegisterRequestModel(
          email: phoneNumber,
          username: name,
          password: otpCode,
          password2: otpCode,
        );

        final tokenResponse = await remoteDataSource.register(request);

        await localDataSource.saveTokens(tokenResponse);
        await localDataSource.setLoggedIn(true);

        return Right(tokenResponse);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message, code: e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message, code: e.code));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure('Registration failed'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.logout();
      }

      await _clearLocalAuthData();
      return const Right(null);
    } catch (e) {
      try {
        await _clearLocalAuthData();
      } catch (_) {}
      return Left(ServerFailure('Logout failed'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser.toEntity());
      }

      if (await networkInfo.isConnected) {
        final userResponse = await remoteDataSource.getCurrentUser();
        await localDataSource.saveUser(userResponse);
        return Right(userResponse.toEntity());
      } else {
        return const Right(null);
      }
    } on AuthException catch (e) {
      if (e.code == '401' || e.code == '403') {
        await _clearLocalAuthData();
      }
      return Left(AuthFailure(e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to get current user'));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final isLoggedIn = await localDataSource.isLoggedIn();
      final accessToken = await localDataSource.getAccessToken();

      return Right(isLoggedIn && accessToken != null);
    } catch (e) {
      return Left(CacheFailure('Failed to check login status'));
    }
  }

  /// Helper method to clear all local authentication data
  Future<void> _clearLocalAuthData() async {
    try {
      await localDataSource.clearTokens();
      await localDataSource.clearUser();
      await localDataSource.setLoggedIn(false);
    } catch (e) {}
  }
}
