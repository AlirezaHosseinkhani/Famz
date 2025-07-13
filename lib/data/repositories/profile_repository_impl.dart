import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/remote/profile_remote_datasource.dart';
import '../models/profile/update_profile_request_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Profile>> getProfile() async {
    if (await networkInfo.isConnected) {
      try {
        final profile = await remoteDataSource.getProfile();
        return Right(profile);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure(
          'Unexpected error occurred',
          code: "500",
        ));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Profile>> updateProfile({
    String? phoneNumber,
    String? bio,
    String? profilePicture,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final request = UpdateProfileRequestModel(
          phoneNumber: phoneNumber,
          bio: bio,
          profilePicture: profilePicture,
        );
        final profile = await remoteDataSource.updateProfile(request);
        return Right(profile);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, code: e.code));
      } catch (e) {
        return Left(ServerFailure('Unexpected error occurred', code: "500"));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Profile>> patchProfile({
    String? phoneNumber,
    String? bio,
    String? profilePicture,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final request = UpdateProfileRequestModel(
          phoneNumber: phoneNumber,
          bio: bio,
          profilePicture: profilePicture,
        );
        final profile = await remoteDataSource.patchProfile(request);
        return Right(profile);
      } on ServerException catch (e) {
        return Left(ServerFailure(
          e.message,
          code: e.code,
        ));
      } catch (e) {
        return Left(ServerFailure('Unexpected error occurred', code: "500"));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
