// lib/data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/auth/check_existence_request_model.dart';
import '../models/auth/check_existence_response_model.dart';
import '../models/auth/login_request_model.dart';
import '../models/auth/register_request_model.dart';
import '../models/auth/token_model.dart';

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
  Future<Either<Failure, CheckExistenceResponseModel>> checkExistence(
      String emailOrPhone) async {
    if (await networkInfo.isConnected) {
      try {
        final request = CheckExistenceRequestModel(phoneNumber: emailOrPhone);
        final result = await remoteDataSource.checkExistence(request);
        return Right(result);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, TokenModel>> login(
      String emailOrPhone, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final request =
            LoginRequestModel(emailOrPhone: emailOrPhone, password: password);
        final response = await remoteDataSource.login(request);

        // Save tokens and user data locally
        await localDataSource.saveTokens(response);
        await localDataSource.saveUsername(response.username!);
        // await localDataSource.saveUser(response.user);
        await localDataSource.setLoggedIn(true);

        return Right(response);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, TokenModel>> register(
      String emailOrPhone, String password, String username) async {
    if (await networkInfo.isConnected) {
      try {
        final request = RegisterRequestModel(
          phoneNumber: emailOrPhone,
          password: password,
          username: username,
          password2: password,
        );
        final tokens = await remoteDataSource.register(request);

        // Save tokens locally
        await localDataSource.saveTokens(tokens);
        await localDataSource.setLoggedIn(true);

        return Right(tokens);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.logout();
      }
    } catch (e) {
      // Continue with local logout even if remote logout fails
    }

    await localDataSource.clearTokens();
    await localDataSource.clearUser();
    await localDataSource.setLoggedIn(false);

    return const Right(null);
  }

  @override
  Future<Either<Failure, TokenModel>> refreshToken(String refreshToken) async {
    if (await networkInfo.isConnected) {
      try {
        final tokens = await remoteDataSource.refreshToken(refreshToken);
        await localDataSource.saveTokens(tokens);
        return Right(tokens);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
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
        final user = await remoteDataSource.getCurrentUser();
        await localDataSource.saveUser(user);
        return Right(user.toEntity());
      } else {
        return const Right(null);
      }
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
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
