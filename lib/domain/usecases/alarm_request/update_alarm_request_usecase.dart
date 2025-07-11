import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/alarm_request.dart';
import '../../repositories/alarm_request_repository.dart';

class UpdateAlarmRequestUseCase {
  final AlarmRequestRepository repository;

  UpdateAlarmRequestUseCase(this.repository);

  Future<Either<Failure, AlarmRequest>> call(
      UpdateAlarmRequestParams params) async {
    return await repository.updateAlarmRequest(
        // id: params.id,
        // message: params.message,
        );
  }
}

class UpdateAlarmRequestParams {
  final int id;
  final String message;

  UpdateAlarmRequestParams({
    required this.id,
    required this.message,
  });
}
