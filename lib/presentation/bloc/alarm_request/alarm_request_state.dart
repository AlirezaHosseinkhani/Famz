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

  List<SentRequest> get typedSentRequests => sentRequests.cast<SentRequest>();
  List<ReceivedRequest> get typedReceivedRequests =>
      receivedRequests.cast<ReceivedRequest>();

  AlarmRequestsLoaded copyWith({
    List<SentRequest>? sentRequests,
    List<ReceivedRequest>? receivedRequests,
  }) {
    return AlarmRequestsLoaded(
      sentRequests: sentRequests ?? this.sentRequests,
      receivedRequests: receivedRequests ?? this.receivedRequests,
    );
  }

  @override
  List<Object?> get props => [sentRequests, receivedRequests];
}

abstract class AlarmRequestOperationSuccess extends AlarmRequestState {
  final String message;

  const AlarmRequestOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AlarmRequestCreated extends AlarmRequestOperationSuccess {
  const AlarmRequestCreated({required super.message});
}

class AlarmRequestUpdated extends AlarmRequestOperationSuccess {
  const AlarmRequestUpdated({required super.message});
}

class AlarmRequestDeleted extends AlarmRequestOperationSuccess {
  const AlarmRequestDeleted({required super.message});
}

class RequestAccepted extends AlarmRequestOperationSuccess {
  const RequestAccepted({required super.message});
}

class RequestRejected extends AlarmRequestOperationSuccess {
  const RequestRejected({required super.message});
}

class AlarmRequestError extends AlarmRequestState {
  final String message;
  final bool isCritical;

  const AlarmRequestError({
    required this.message,
    this.isCritical = false,
  });

  @override
  List<Object?> get props => [message, isCritical];
}
