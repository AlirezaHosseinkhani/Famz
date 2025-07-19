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
    // on<GetSentRequestsEvent>(_onGetSentRequests);
    // on<GetReceivedRequestsEvent>(_onGetReceivedRequests);
    on<LoadAllRequestsEvent>(_onLoadAllRequests);
    on<CreateAlarmRequestEvent>(_onCreateAlarmRequest);
    on<UpdateAlarmRequestEvent>(_onUpdateAlarmRequest);
    on<DeleteAlarmRequestEvent>(_onDeleteAlarmRequest);
    on<AcceptRequestEvent>(_onAcceptRequest);
    on<RejectRequestEvent>(_onRejectRequest);
    on<RefreshRequestsEvent>(_onRefreshRequests);
  }

  // Future<void> _onGetSentRequests(
  //   GetSentRequestsEvent event,
  //   Emitter<AlarmRequestState> emit,
  // ) async {
  //   // Preserve existing received requests if available
  //   final currentReceived = state is AlarmRequestsLoaded
  //       ? (state as AlarmRequestsLoaded).receivedRequests
  //       : <ReceivedRequest>[];
  //
  //   emit(AlarmRequestLoading(preserveData: currentReceived.isNotEmpty));
  //
  //   final result = await getSentRequestsUseCase.call();
  //
  //   result.fold(
  //     (failure) =>
  //         emit(AlarmRequestError(message: _mapFailureToMessage(failure))),
  //     (sentRequests) {
  //       // Ensure the list is properly typed
  //       final typedSentRequests = sentRequests is List<SentRequest>
  //           ? sentRequests
  //           : sentRequests.cast<SentRequest>();
  //
  //       emit(AlarmRequestsLoaded(
  //         receivedRequests: currentReceived,
  //         sentRequests: typedSentRequests,
  //       ));
  //     },
  //   );
  // }
  //
  // Future<void> _onGetReceivedRequests(
  //   GetReceivedRequestsEvent event,
  //   Emitter<AlarmRequestState> emit,
  // ) async {
  //   // Preserve existing sent requests if available
  //   final currentSent = state is AlarmRequestsLoaded
  //       ? (state as AlarmRequestsLoaded).sentRequests
  //       : <SentRequest>[];
  //
  //   emit(AlarmRequestLoading(preserveData: currentSent.isNotEmpty));
  //
  //   final result = await getReceivedRequestsUseCase.call();
  //
  //   result.fold(
  //     (failure) =>
  //         emit(AlarmRequestError(message: _mapFailureToMessage(failure))),
  //     (receivedRequests) {
  //       // Ensure the list is properly typed
  //       final typedReceivedRequests = receivedRequests is List<ReceivedRequest>
  //           ? receivedRequests
  //           : receivedRequests.cast<ReceivedRequest>();
  //
  //       emit(AlarmRequestsLoaded(
  //         receivedRequests: typedReceivedRequests,
  //         sentRequests: currentSent,
  //       ));
  //     },
  //   );
  // }

  Future<void> _onLoadAllRequests(
    LoadAllRequestsEvent event,
    Emitter<AlarmRequestState> emit,
  ) async {
    emit(AlarmRequestLoading());

    final sentResult = await getSentRequestsUseCase.call();
    final receivedResult = await getReceivedRequestsUseCase.call();

    // Prefer showing an error if either fails
    final failure = sentResult.fold((l) => l, (_) => null) ??
        receivedResult.fold((l) => l, (_) => null);

    if (failure != null) {
      emit(AlarmRequestError(message: _mapFailureToMessage(failure)));
      return;
    }

    final sentRequests = sentResult.getOrElse(() => []);
    final receivedRequests = receivedResult.getOrElse(() => []);

    emit(AlarmRequestsLoaded(
      sentRequests: sentRequests,
      receivedRequests: receivedRequests,
    ));
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
      (_) {
        // After successful creation, refresh both lists
        // add(GetSentRequestsEvent());
        // add(GetReceivedRequestsEvent());
        add(LoadAllRequestsEvent());
      },
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
    // add(GetSentRequestsEvent());
    // add(GetReceivedRequestsEvent());
    add(LoadAllRequestsEvent());
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
