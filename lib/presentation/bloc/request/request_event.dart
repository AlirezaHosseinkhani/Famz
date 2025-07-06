import 'package:equatable/equatable.dart';

abstract class RequestEvent extends Equatable {
  const RequestEvent();

  @override
  List<Object?> get props => [];
}

class GetSentRequestsRequested extends RequestEvent {}

class GetReceivedRequestsRequested extends RequestEvent {}

class CreateRequestRequested extends RequestEvent {
  final int toUserId;
  final String message;

  const CreateRequestRequested({
    required this.toUserId,
    required this.message,
  });

  @override
  List<Object> get props => [toUserId, message];
}

class AcceptRequestRequested extends RequestEvent {
  final int requestId;

  const AcceptRequestRequested({required this.requestId});

  @override
  List<Object> get props => [requestId];
}

class RejectRequestRequested extends RequestEvent {
  final int requestId;

  const RejectRequestRequested({required this.requestId});

  @override
  List<Object> get props => [requestId];
}

class DeleteRequestRequested extends RequestEvent {
  final int requestId;

  const DeleteRequestRequested({required this.requestId});

  @override
  List<Object> get props => [requestId];
}
