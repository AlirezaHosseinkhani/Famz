import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
// import '../../entities/received_request.dart';
import '../../repositories/alarm_request_repository.dart';

class AcceptRequestUseCase {
  final AlarmRequestRepository repository;

  AcceptRequestUseCase(this.repository);

  // Future<Either<Failure, ReceivedRequest>> call(int requestId) async {
  Future<Either<Failure, String>> call(int requestId) async {
    return await repository.acceptRequest(requestId);
  }
}
