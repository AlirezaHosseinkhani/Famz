import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/alarm_request_repository.dart';

class RejectRequestUseCase {
  final AlarmRequestRepository repository;

  RejectRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(RejectRequestParams params) async {
    return await repository.rejectRequest(params.requestId);
  }
}

class RejectRequestParams extends Equatable {
  final int requestId;

  const RejectRequestParams({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}
