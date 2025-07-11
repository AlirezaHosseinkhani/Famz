import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
// import '../../entities/received_request.dart';
import '../../../domain/entities/alarm_request.dart';
import '../../repositories/alarm_request_repository.dart';

class GetReceivedRequestsUseCase {
  final AlarmRequestRepository repository;

  GetReceivedRequestsUseCase(this.repository);

  // Future<Either<Failure, List<ReceivedRequest>>> call() async {
  Future<Either<Failure, List<AlarmRequest>>> call() async {
    return await repository.getReceivedRequests();
  }
}
