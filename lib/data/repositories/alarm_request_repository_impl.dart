import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/received_request.dart';
import '../../domain/entities/sent_request.dart';
import '../../domain/repositories/alarm_request_repository.dart';
import '../datasources/remote/alarm_request_remote_datasource.dart';

class AlarmRequestRepositoryImpl implements AlarmRequestRepository {
  final AlarmRequestRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AlarmRequestRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<SentRequest>>> getSentRequests() async {
    if (await networkInfo.isConnected) {
      try {
        final sentRequestModels = await remoteDataSource.getSentRequests();
        final sentRequests =
            sentRequestModels.map((model) => model.toEntity()).toList();
        return Right(sentRequests);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, code: e.code));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<ReceivedRequest>>> getReceivedRequests() async {
    if (await networkInfo.isConnected) {
      try {
        final receivedRequestModels =
            await remoteDataSource.getReceivedRequests();
        final receivedRequests =
            receivedRequestModels.map((model) => model.toEntity()).toList();
        return Right(receivedRequests);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, code: e.code));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, SentRequest>> createAlarmRequest({
    required int toUserId,
    required String message,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final sentRequestModel = await remoteDataSource.createAlarmRequest(
          toUserId: toUserId,
          message: message,
        );
        return Right(sentRequestModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, code: e.code));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, SentRequest>> updateAlarmRequest({
    required int requestId,
    required String message,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final sentRequestModel = await remoteDataSource.updateAlarmRequest(
          requestId: requestId,
          message: message,
        );
        return Right(sentRequestModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, code: e.code));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAlarmRequest(int requestId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteAlarmRequest(requestId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, code: e.code));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> acceptRequest(int requestId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.acceptRequest(requestId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, code: e.code));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> rejectRequest(int requestId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.rejectRequest(requestId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, code: e.code));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }
}
