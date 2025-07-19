import 'package:equatable/equatable.dart';

abstract class AlarmRequestEvent extends Equatable {
  const AlarmRequestEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllRequestsEvent extends AlarmRequestEvent {}

class CreateAlarmRequestEvent extends AlarmRequestEvent {
  final int toUserId;
  final String message;

  const CreateAlarmRequestEvent({
    required this.toUserId,
    required this.message,
  });

  @override
  List<Object?> get props => [toUserId, message];
}

class UpdateAlarmRequestEvent extends AlarmRequestEvent {
  final int requestId;
  final String message;

  const UpdateAlarmRequestEvent({
    required this.requestId,
    required this.message,
  });

  @override
  List<Object?> get props => [requestId, message];
}

class DeleteAlarmRequestEvent extends AlarmRequestEvent {
  final int requestId;

  const DeleteAlarmRequestEvent({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}

class AcceptRequestEvent extends AlarmRequestEvent {
  final int requestId;

  const AcceptRequestEvent({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}

class RejectRequestEvent extends AlarmRequestEvent {
  final int requestId;

  const RejectRequestEvent({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}

class RefreshRequestsEvent extends AlarmRequestEvent {}
