import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/alarm.dart';
import '../../domain/repositories/alarm_repository.dart';
import '../datasources/local/alarm_local_datasource.dart';
import '../datasources/remote/alarm_remote_datasource.dart';

class AlarmRepositoryImpl implements AlarmRepository {
  final AlarmRemoteDataSource remoteDataSource;
  final AlarmLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AlarmRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Alarm>> createAlarm({
    required DateTime time,
    required bool isActive,
    int? recordingId,
    List<int>? repeatDays,
    String? label,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final alarmModel = await remoteDataSource.createAlarm(
          time: time,
          isActive: isActive,
          recordingId: recordingId,
          repeatDays: repeatDays,
          label: label,
        );

        await localDataSource.cacheAlarm(alarmModel);
        return Right(alarmModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAlarm(int alarmId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.deleteAlarm(alarmId);
        await localDataSource.deleteAlarm(alarmId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<Alarm>>> getAlarms() async {
    if (await networkInfo.isConnected) {
      try {
        final alarmModels = await remoteDataSource.getAlarms();
        await localDataSource.cacheAlarms(alarmModels);
        return Right(alarmModels.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        try {
          final cachedAlarms = await localDataSource.getCachedAlarms();
          return Right(cachedAlarms.map((model) => model.toEntity()).toList());
        } on CacheException {
          return Left(ServerFailure(e.message));
        }
      }
    } else {
      try {
        final cachedAlarms = await localDataSource.getCachedAlarms();
        return Right(cachedAlarms.map((model) => model.toEntity()).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, Alarm>> toggleAlarm(int id, bool isActive) async {
    if (await networkInfo.isConnected) {
      try {
        final alarmModel = await remoteDataSource.toggleAlarm(id, isActive);
        await localDataSource.cacheAlarm(alarmModel);
        return Right(alarmModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Alarm>> updateAlarm({
    required int id,
    DateTime? time,
    bool? isActive,
    int? recordingId,
    List<int>? repeatDays,
    String? label,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final alarmModel = await remoteDataSource.updateAlarm(
          id: id,
          time: time,
          isActive: isActive,
          recordingId: recordingId,
          repeatDays: repeatDays,
          label: label,
        );

        await localDataSource.cacheAlarm(alarmModel);
        return Right(alarmModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
