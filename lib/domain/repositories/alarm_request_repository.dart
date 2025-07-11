import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/alarm_request.dart';

abstract class AlarmRequestRepository {
  Future<Either<Failure, String>> acceptRequest(int requestId);

  Future<Either<Failure, AlarmRequest>> createAlarmRequest();

  Future<Either<Failure, String>> deleteAlarmRequest(int requestId);

  Future<Either<Failure, List<AlarmRequest>>> getReceivedRequests();

  Future<Either<Failure, List<AlarmRequest>>> getSentRequests();

  Future<Either<Failure, String>> rejectRequest(int requestId);

  Future<Either<Failure, AlarmRequest>> updateAlarmRequest();
}
