import 'package:equatable/equatable.dart';

import '../../../domain/entities/alarm_request.dart';

abstract class RequestState extends Equatable {
  const RequestState();

  @override
  List<Object?> get props => [];
}

class RequestInitial extends RequestState {}

class RequestLoading extends RequestState {}

class SentRequestsLoaded extends RequestState {
  final List<AlarmRequest> requests;

  const SentRequestsLoaded({required this.requests});

  @override
  List<Object> get props => [requests];
}

class ReceivedRequestsLoaded extends RequestState {
  final List<AlarmRequest> requests;

  const ReceivedRequestsLoaded({required this.requests});

  @override
  List<Object> get props => [requests];
}

class RequestError extends RequestState {
  final String message;

  const RequestError({required this.message});

  @override
  List<Object> get props => [message];
}

class RequestCreated extends RequestState {
  final AlarmRequest request;

  const RequestCreated({required this.request});

  @override
  List<Object> get props => [request];
}

class RequestAccepted extends RequestState {
  final int requestId;

  const RequestAccepted({required this.requestId});

  @override
  List<Object> get props => [requestId];
}

class RequestRejected extends RequestState {
  final int requestId;

  const RequestRejected({required this.requestId});

  @override
  List<Object> get props => [requestId];
}

class RequestDeleted extends RequestState {
  final int requestId;

  const RequestDeleted({required this.requestId});

  @override
  List<Object> get props => [requestId];
}
