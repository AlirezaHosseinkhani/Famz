import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/usecases/alarm_request/accept_request_usecase.dart';
import '../../../domain/usecases/alarm_request/create_alarm_request_usecase.dart';
import '../../../domain/usecases/alarm_request/delete_alarm_request_usecase.dart';
import '../../../domain/usecases/alarm_request/get_received_requests_usecase.dart';
import '../../../domain/usecases/alarm_request/get_sent_requests_usecase.dart';
import '../../../domain/usecases/alarm_request/reject_request_usecase.dart';
import '../../../domain/usecases/alarm_request/update_alarm_request_usecase.dart';
import 'alarm_request_event.dart';
import 'alarm_request_state.dart';

class AlarmRequestBloc extends Bloc<AlarmRequestEvent, AlarmRequestState> {
  final GetSentRequestsUseCase getSentRequestsUseCase;
  final GetReceivedRequestsUseCase getReceivedRequestsUseCase;
  final CreateAlarmRequestUseCase createAlarmRequestUseCase;
  final UpdateAlarmRequestUseCase updateAlarmRequestUseCase;
  final DeleteAlarmRequestUseCase deleteAlarmRequestUseCase;
  final AcceptRequestUseCase acceptRequestUseCase;
  final RejectRequestUseCase rejectRequestUseCase;

  AlarmRequestBloc({
    required this.getSentRequestsUseCase,
    required this.getReceivedRequestsUseCase,
    required this.createAlarmRequestUseCase,
    required this.updateAlarmRequestUseCase,
    required this.deleteAlarmRequestUseCase,
    required this.acceptRequestUseCase,
    required this.rejectRequestUseCase,
  }) : super(AlarmRequestInitial()) {
    on<GetSentRequestsEvent>(_onGetSentRequests);
    on<GetReceivedRequestsEvent>(_onGetReceivedRequests);
    on<CreateAlarmRequestEvent>(_onCreateAlarmRequest);
    on<UpdateAlarmRequestEvent>(_onUpdateAlarmRequest);
    on<DeleteAlarmRequestEvent>(_onDeleteAlarmRequest);
    on<AcceptRequestEvent>(_onAcceptRequest);
    on<RejectRequestEvent>(_onRejectRequest);
    on<RefreshRequestsEvent>(_onRefreshRequests);
  }

  Future<void> _onGetSentRequests(
    GetSentRequestsEvent event,
    Emitter<AlarmRequestState> emit,
  ) async {
    emit(AlarmRequestLoading());

    final result = await getSentRequestsUseCase.call();

    result.fold(
      (failure) =>
          emit(AlarmRequestError(message: _mapFailureToMessage(failure))),
      (sentRequests) => emit(SentRequestsLoaded(sentRequests: sentRequests)),
    );
  }

  Future<void> _onGetReceivedRequests(
    GetReceivedRequestsEvent event,
    Emitter<AlarmRequestState> emit,
  ) async {
    emit(AlarmRequestLoading());

    final result = await getReceivedRequestsUseCase.call();

    result.fold(
      (failure) =>
          emit(AlarmRequestError(message: _mapFailureToMessage(failure))),
      (receivedRequests) =>
          emit(ReceivedRequestsLoaded(receivedRequests: receivedRequests)),
    );
  }

  Future<void> _onCreateAlarmRequest(
    CreateAlarmRequestEvent event,
    Emitter<AlarmRequestState> emit,
  ) async {
    emit(AlarmRequestLoading());

    final result = await createAlarmRequestUseCase.call(
      CreateAlarmRequestParams(
        toUserId: event.toUserId,
        message: event.message,
      ),
    );

    result.fold(
      (failure) =>
          emit(AlarmRequestError(message: _mapFailureToMessage(failure))),
      (_) =>
          emit(const AlarmRequestCreated(message: 'Request sent successfully')),
    );
  }

  Future<void> _onUpdateAlarmRequest(
    UpdateAlarmRequestEvent event,
    Emitter<AlarmRequestState> emit,
  ) async {
    emit(AlarmRequestLoading());

    final result = await updateAlarmRequestUseCase.call(
      UpdateAlarmRequestParams(
        requestId: event.requestId,
        message: event.message,
      ),
    );

    result.fold(
      (failure) =>
          emit(AlarmRequestError(message: _mapFailureToMessage(failure))),
      (_) => emit(
          const AlarmRequestUpdated(message: 'Request updated successfully')),
    );
  }

  Future<void> _onDeleteAlarmRequest(
    DeleteAlarmRequestEvent event,
    Emitter<AlarmRequestState> emit,
  ) async {
    emit(AlarmRequestLoading());

    final result = await deleteAlarmRequestUseCase.call(
      DeleteAlarmRequestParams(requestId: event.requestId),
    );

    result.fold(
      (failure) =>
          emit(AlarmRequestError(message: _mapFailureToMessage(failure))),
      (_) => emit(
          const AlarmRequestDeleted(message: 'Request deleted successfully')),
    );
  }

  Future<void> _onAcceptRequest(
    AcceptRequestEvent event,
    Emitter<AlarmRequestState> emit,
  ) async {
    emit(AlarmRequestLoading());

    final result = await acceptRequestUseCase.call(
      AcceptRequestParams(requestId: event.requestId),
    );

    result.fold(
      (failure) =>
          emit(AlarmRequestError(message: _mapFailureToMessage(failure))),
      (_) =>
          emit(const RequestAccepted(message: 'Request accepted successfully')),
    );
  }

  Future<void> _onRejectRequest(
    RejectRequestEvent event,
    Emitter<AlarmRequestState> emit,
  ) async {
    emit(AlarmRequestLoading());

    final result = await rejectRequestUseCase.call(
      RejectRequestParams(requestId: event.requestId),
    );

    result.fold(
      (failure) =>
          emit(AlarmRequestError(message: _mapFailureToMessage(failure))),
      (_) =>
          emit(const RequestRejected(message: 'Request rejected successfully')),
    );
  }

  Future<void> _onRefreshRequests(
    RefreshRequestsEvent event,
    Emitter<AlarmRequestState> emit,
  ) async {
    // Refresh both sent and received requests
    add(GetSentRequestsEvent());
    add(GetReceivedRequestsEvent());
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred';
      case NetworkFailure:
        return 'Network error occurred';
      case CacheFailure:
        return 'Cache error occurred';
      default:
        return 'Unexpected error occurred';
    }
  }
}
