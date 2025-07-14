import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../entities/sent_request.dart';
import '../../repositories/alarm_request_repository.dart';

class CreateAlarmRequestUseCase {
  final AlarmRequestRepository repository;

  CreateAlarmRequestUseCase(this.repository);

  Future<Either<Failure, SentRequest>> call(
      CreateAlarmRequestParams params) async {
    return await repository.createAlarmRequest(
      toUserId: params.toUserId,
      message: params.message,
    );
  }
}

class CreateAlarmRequestParams extends Equatable {
  final int toUserId;
  final String message;

  const CreateAlarmRequestParams({
    required this.toUserId,
    required this.message,
  });

  @override
  List<Object?> get props => [toUserId, message];
}
