import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
// import '../../entities/received_request.dart';
import '../../repositories/alarm_request_repository.dart';

class RejectRequestUseCase {
  final AlarmRequestRepository repository;

  RejectRequestUseCase(this.repository);

  // Future<Either<Failure, ReceivedRequest>> call(int requestId) async {
  Future<Either<Failure, String>> call(int requestId) async {
    return await repository.rejectRequest(requestId);
  }
}
