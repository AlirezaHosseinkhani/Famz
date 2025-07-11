import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/alarm_request.dart';
import '../../repositories/alarm_request_repository.dart';

class CreateAlarmRequestUseCase {
  final AlarmRequestRepository repository;

  CreateAlarmRequestUseCase(this.repository);

  Future<Either<Failure, AlarmRequest>> call(
      CreateAlarmRequestParams params) async {
    return await repository.createAlarmRequest(
        // toUserId: params.toUserId,
        // message: params.message,
        );
  }
}

class CreateAlarmRequestParams {
  final int toUserId;
  final String message;

  CreateAlarmRequestParams({
    required this.toUserId,
    required this.message,
  });
}
