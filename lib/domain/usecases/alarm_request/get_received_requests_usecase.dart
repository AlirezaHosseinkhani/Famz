import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/received_request.dart';
import '../../repositories/alarm_request_repository.dart';

class GetReceivedRequestsUseCase {
  final AlarmRequestRepository repository;

  GetReceivedRequestsUseCase(this.repository);

  Future<Either<Failure, List<ReceivedRequest>>> call() async {
    return await repository.getReceivedRequests();
  }
}
