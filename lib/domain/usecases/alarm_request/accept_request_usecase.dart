import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/alarm_request_repository.dart';

class AcceptRequestUseCase {
  final AlarmRequestRepository repository;

  AcceptRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(AcceptRequestParams params) async {
    return await repository.acceptRequest(params.requestId);
  }
}

class AcceptRequestParams extends Equatable {
  final int requestId;

  const AcceptRequestParams({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}
