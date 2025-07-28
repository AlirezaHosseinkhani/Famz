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
    on<LoadAllRequestsEvent>(_onLoadAllRequests);
    on<CreateAlarmRequestEvent>(_onCreateAlarmRequest);
    on<UpdateAlarmRequestEvent>(_onUpdateAlarmRequest);
    on<DeleteAlarmRequestEvent>(_onDeleteAlarmRequest);
    on<AcceptRequestEvent>(_onAcceptRequest);
    on<RejectRequestEvent>(_onRejectRequest);
    on<RefreshRequestsEvent>(_onRefreshRequests);
  }

  Future<void> _onLoadAllRequests(
    LoadAllRequestsEvent event,
    Emitter<AlarmRequestState> emit,
  ) async {
    emit(AlarmRequestLoading());

    final sentResult = await getSentRequestsUseCase.call();
    final receivedResult = await getReceivedRequestsUseCase.call();

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

    await result.fold(
      (failure) async {
        emit(AlarmRequestError(message: _mapFailureToMessage(failure)));
      },
      (_) async {
        // Emit success state first
        emit(
            const AlarmRequestCreated(message: 'Request created successfully'));

        // Then reload all requests to get updated lists
        await _reloadAllRequests(emit);
      },
    );
  }

  Future<void> _onUpdateAlarmRequest(
    UpdateAlarmRequestEvent event,
    Emitter<AlarmRequestState> emit,
  ) async {
    emit(AlarmRequestLoading(preserveData: true));

    final result = await updateAlarmRequestUseCase.call(
      UpdateAlarmRequestParams(
        requestId: event.requestId,
        message: event.message,
      ),
    );

    await result.fold(
      (failure) async {
        emit(AlarmRequestError(message: _mapFailureToMessage(failure)));
      },
      (_) async {
        // Emit success state first
        emit(
            const AlarmRequestUpdated(message: 'Request updated successfully'));

        // Then reload all requests to get updated lists
        await _reloadAllRequests(emit);
      },
    );
  }

  Future<void> _onDeleteAlarmRequest(
    DeleteAlarmRequestEvent event,
    Emitter<AlarmRequestState> emit,
  ) async {
    emit(AlarmRequestLoading(preserveData: true));

    final result = await deleteAlarmRequestUseCase.call(
      DeleteAlarmRequestParams(requestId: event.requestId),
    );

    await result.fold(
      (failure) async {
        emit(AlarmRequestError(message: _mapFailureToMessage(failure)));
      },
      (_) async {
        // Emit success state first
        emit(
            const AlarmRequestDeleted(message: 'Request deleted successfully'));

        // Then reload all requests to get updated lists
        await _reloadAllRequests(emit);
      },
    );
  }

  Future<void> _onAcceptRequest(
    AcceptRequestEvent event,
    Emitter<AlarmRequestState> emit,
  ) async {
    emit(AlarmRequestLoading(preserveData: true));

    final result = await acceptRequestUseCase.call(
      AcceptRequestParams(requestId: event.requestId),
    );

    await result.fold(
      (failure) async {
        emit(AlarmRequestError(message: _mapFailureToMessage(failure)));
      },
      (_) async {
        // Emit success state first
        emit(const RequestAccepted(message: 'Request accepted successfully'));

        // Then reload all requests to get updated lists
        await _reloadAllRequests(emit);
      },
    );
  }

  Future<void> _onRejectRequest(
    RejectRequestEvent event,
    Emitter<AlarmRequestState> emit,
  ) async {
    emit(AlarmRequestLoading(preserveData: true));

    final result = await rejectRequestUseCase.call(
      RejectRequestParams(requestId: event.requestId),
    );

    await result.fold(
      (failure) async {
        emit(AlarmRequestError(message: _mapFailureToMessage(failure)));
      },
      (_) async {
        // Emit success state first
        emit(const RequestRejected(message: 'Request rejected successfully'));

        // Then reload all requests to get updated lists
        await _reloadAllRequests(emit);
      },
    );
  }

  Future<void> _onRefreshRequests(
    RefreshRequestsEvent event,
    Emitter<AlarmRequestState> emit,
  ) async {
    await _reloadAllRequests(emit);
  }

  // Helper method to reload all requests
  Future<void> _reloadAllRequests(Emitter<AlarmRequestState> emit) async {
    final sentResult = await getSentRequestsUseCase.call();
    final receivedResult = await getReceivedRequestsUseCase.call();

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
