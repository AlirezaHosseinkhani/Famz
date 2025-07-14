import 'package:equatable/equatable.dart';

import '../../../domain/entities/received_request.dart';
import '../../../domain/entities/sent_request.dart';

abstract class AlarmRequestState extends Equatable {
  const AlarmRequestState();

  @override
  List<Object?> get props => [];
}

class AlarmRequestInitial extends AlarmRequestState {}

class AlarmRequestLoading extends AlarmRequestState {}

class SentRequestsLoaded extends AlarmRequestState {
  final List<SentRequest> sentRequests;

  const SentRequestsLoaded({required this.sentRequests});

  @override
  List<Object?> get props => [sentRequests];
}

class ReceivedRequestsLoaded extends AlarmRequestState {
  final List<ReceivedRequest> receivedRequests;

  const ReceivedRequestsLoaded({required this.receivedRequests});

  @override
  List<Object?> get props => [receivedRequests];
}

class AlarmRequestCreated extends AlarmRequestState {
  final String message;

  const AlarmRequestCreated({required this.message});

  @override
  List<Object?> get props => [message];
}

class AlarmRequestUpdated extends AlarmRequestState {
  final String message;

  const AlarmRequestUpdated({required this.message});

  @override
  List<Object?> get props => [message];
}

class AlarmRequestDeleted extends AlarmRequestState {
  final String message;

  const AlarmRequestDeleted({required this.message});

  @override
  List<Object?> get props => [message];
}

class RequestAccepted extends AlarmRequestState {
  final String message;

  const RequestAccepted({required this.message});

  @override
  List<Object?> get props => [message];
}

class RequestRejected extends AlarmRequestState {
  final String message;

  const RequestRejected({required this.message});

  @override
  List<Object?> get props => [message];
}

class AlarmRequestError extends AlarmRequestState {
  final String message;

  const AlarmRequestError({required this.message});

  @override
  List<Object?> get props => [message];
}
