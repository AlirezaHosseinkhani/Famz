import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/record_alarm_request.dart';
import '../../domain/repositories/record_alarm_repository.dart';
import '../datasources/remote/record_alarm_remote_datasource.dart';
import '../models/alarm/upload_recording_request_model.dart';

class RecordAlarmRepositoryImpl implements RecordAlarmRepository {
  final RecordAlarmRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  RecordAlarmRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, RecordAlarmRequest>> uploadRecording({
    required int requestId,
    required String recordingType,
    File? audioFile,
    File? videoFile,
    required Duration duration,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final uploadRequest = UploadRecordingRequestModel(
          requestId: requestId,
          audioFile: audioFile,
          videoFile: videoFile,
          duration: duration,
          recordingType: recordingType,
        );

        final result = await remoteDataSource.uploadRecording(uploadRequest);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecording(int recordingId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteRecording(recordingId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, RecordAlarmRequest>> updateRecording({
    required int recordingId,
    required int requestId,
    required String recordingType,
    File? audioFile,
    File? videoFile,
    required Duration duration,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final uploadRequest = UploadRecordingRequestModel(
          requestId: requestId,
          audioFile: audioFile,
          videoFile: videoFile,
          duration: duration,
          recordingType: recordingType,
        );

        final result = await remoteDataSource.updateRecording(
          recordingId,
          uploadRequest,
        );
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
