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
        return Right("response.message");
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message, code: e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message, code: e.code));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure('Unexpected error occurred'));
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
        return Left(ServerFailure('Unexpected error occurred'));
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
        return Left(ServerFailure('Unexpected error occurred'));
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
        // Create the register request with the correct parameters
        final request = RegisterRequestModel(
          email: phoneNumber, // Using phoneNumber as email
          username: name,
          password: otpCode, // You might want to generate a random password
          password2: otpCode, // Same as password
          // phoneNumber: phoneNumber,
        );

        final tokenResponse = await remoteDataSource.register(request);

        await localDataSource.saveTokens(tokenResponse);
        await localDataSource.setLoggedIn(true);

        // await localDataSource.saveUser(userResponse);
        // await localDataSource.setLoggedIn(true);

        return Right(tokenResponse);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message, code: e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message, code: e.code));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure('Unexpected error occurred'));
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
      await localDataSource.clearTokens();
      await localDataSource.clearUser();
      await localDataSource.setLoggedIn(false);
      return const Right(null);
    } on AuthException catch (e) {
      // Even if logout fails on server, clear local data
      await localDataSource.clearTokens();
      await localDataSource.clearUser();
      await localDataSource.setLoggedIn(false);
      return Left(AuthFailure(e.message, code: e.code));
    } catch (e) {
      // Even if logout fails, clear local data
      await localDataSource.clearTokens();
      await localDataSource.clearUser();
      await localDataSource.setLoggedIn(false);
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, User>> refreshToken() async {
    if (await networkInfo.isConnected) {
      try {
        final currentRefreshToken = await localDataSource.getRefreshToken();
        if (currentRefreshToken == null) {
          return const Left(AuthFailure('No refresh token found'));
        }

        final tokenResponse =
            await remoteDataSource.refreshToken(currentRefreshToken);
        await localDataSource.saveTokens(tokenResponse);

        final userResponse = await remoteDataSource.getCurrentUser();
        await localDataSource.saveUser(userResponse);

        return Right(userResponse.toEntity());
      } on AuthException catch (e) {
        await localDataSource.clearTokens();
        await localDataSource.clearUser();
        await localDataSource.setLoggedIn(false);
        return Left(AuthFailure(e.message, code: e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message, code: e.code));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure('Unexpected error occurred'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
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
      return Left(AuthFailure(e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final isLoggedIn = await localDataSource.isLoggedIn();
      return Right(isLoggedIn);
    } catch (e) {
      return Left(CacheFailure('Failed to check login status'));
    }
  }
}
