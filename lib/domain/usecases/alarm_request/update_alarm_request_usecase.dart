import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../entities/sent_request.dart';
import '../../repositories/alarm_request_repository.dart';

class UpdateAlarmRequestUseCase {
  final AlarmRequestRepository repository;

  UpdateAlarmRequestUseCase(this.repository);

  Future<Either<Failure, SentRequest>> call(
      UpdateAlarmRequestParams params) async {
    return await repository.updateAlarmRequest(
      requestId: params.requestId,
      message: params.message,
    );
  }
}

class UpdateAlarmRequestParams extends Equatable {
  final int requestId;
  final String message;

  const UpdateAlarmRequestParams({
    required this.requestId,
    required this.message,
  });

  @override
  List<Object?> get props => [requestId, message];
}
