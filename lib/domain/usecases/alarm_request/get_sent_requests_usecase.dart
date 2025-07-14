import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/sent_request.dart';
import '../../repositories/alarm_request_repository.dart';

class GetSentRequestsUseCase {
  final AlarmRequestRepository repository;

  GetSentRequestsUseCase(this.repository);

  Future<Either<Failure, List<SentRequest>>> call() async {
    return await repository.getSentRequests();
  }
}
