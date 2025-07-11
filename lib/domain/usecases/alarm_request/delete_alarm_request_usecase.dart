import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/alarm_request_repository.dart';

class DeleteAlarmRequestUseCase {
  final AlarmRequestRepository repository;

  DeleteAlarmRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(int requestId) async {
    return await repository.deleteAlarmRequest(requestId);
  }
}
