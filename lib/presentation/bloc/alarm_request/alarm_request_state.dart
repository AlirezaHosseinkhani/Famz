import 'package:equatable/equatable.dart';

import '../../../domain/entities/received_request.dart';
import '../../../domain/entities/sent_request.dart';

abstract class AlarmRequestState extends Equatable {
  const AlarmRequestState();

  @override
  List<Object?> get props => [];
}

class AlarmRequestInitial extends AlarmRequestState {}

class AlarmRequestLoading extends AlarmRequestState {
  final bool preserveData;

  const AlarmRequestLoading({this.preserveData = false});

  @override
  List<Object?> get props => [preserveData];
}

class AlarmRequestsLoaded extends AlarmRequestState {
  final List<SentRequest> sentRequests;
  final List<ReceivedRequest> receivedRequests;

  const AlarmRequestsLoaded({
    required this.sentRequests,
    required this.receivedRequests,
  });

  @override
  List<Object?> get props => [sentRequests, receivedRequests];
}

class AlarmRequestError extends AlarmRequestState {
  final String message;

  const AlarmRequestError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Base class for all operation success states
abstract class AlarmRequestOperationSuccess extends AlarmRequestState {
  final String message;

  const AlarmRequestOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AlarmRequestCreated extends AlarmRequestOperationSuccess {
  const AlarmRequestCreated({required String message})
      : super(message: message);
}

class AlarmRequestUpdated extends AlarmRequestOperationSuccess {
  const AlarmRequestUpdated({required String message})
      : super(message: message);
}

class AlarmRequestDeleted extends AlarmRequestOperationSuccess {
  const AlarmRequestDeleted({required String message})
      : super(message: message);
}

class RequestAccepted extends AlarmRequestOperationSuccess {
  const RequestAccepted({required String message}) : super(message: message);
}

class RequestRejected extends AlarmRequestOperationSuccess {
  const RequestRejected({required String message}) : super(message: message);
}
