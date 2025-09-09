import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/received_request.dart';
import '../entities/sent_request.dart';

abstract class AlarmRequestRepository {
  Future<Either<Failure, List<SentRequest>>> getSentRequests();

  Future<Either<Failure, List<ReceivedRequest>>> getReceivedRequests();

  Future<Either<Failure, SentRequest>> createAlarmRequest({
    required String toUserId,
    required String message,
  });

  Future<Either<Failure, SentRequest>> updateAlarmRequest({
    required int requestId,
    required String message,
  });

  Future<Either<Failure, void>> deleteAlarmRequest(int requestId);

  Future<Either<Failure, void>> acceptRequest(int requestId);

  Future<Either<Failure, void>> rejectRequest(int requestId);
}
