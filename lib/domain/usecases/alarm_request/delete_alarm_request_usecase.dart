import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/alarm_request_repository.dart';

class DeleteAlarmRequestUseCase {
  final AlarmRequestRepository repository;

  DeleteAlarmRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(DeleteAlarmRequestParams params) async {
    return await repository.deleteAlarmRequest(params.requestId);
  }
}

class DeleteAlarmRequestParams extends Equatable {
  final int requestId;

  const DeleteAlarmRequestParams({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}
