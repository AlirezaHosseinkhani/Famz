import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../domain/entities/received_request.dart';
import '../../../domain/entities/sent_request.dart';
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

  // Cache for current requests
  List<SentRequest> _cachedSentRequests = [];
  List<ReceivedRequest> _cachedReceivedRequests = [];

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
    emit(const AlarmRequestLoading());
    await _loadAndEmitRequests(emit);
  }

  Future<void> _onCreateAlarmRequest(
    CreateAlarmRequestEvent event,
    Emitter<AlarmRequestState> emit,
  ) async {
    // Show loading with preserved data
    emit(const AlarmRequestLoading(preserveData: true));

    final result = await createAlarmRequestUseCase.call(
      CreateAlarmRequestParams(
        toUserId: event.toUserId,
        message: event.message,
      ),
    );

    await result.fold(
      (failure) async {
        emit(AlarmRequestError(message: _mapFailureToMessage(failure)));
        // Restore previous state after error
        if (_cachedSentRequests.isNotEmpty ||
            _cachedReceivedRequests.isNotEmpty) {
          await Future.delayed(const Duration(seconds: 2));
          emit(AlarmRequestsLoaded(
            sentRequests: _cachedSentRequests,
            receivedRequests: _cachedReceivedRequests,
          ));
        }
      },
      (_) async {
        // Emit success state
        emit(
            const AlarmRequestCreated(message: 'Request created successfully'));

        // Wait a bit for the snackbar to show
        await Future.delayed(const Duration(milliseconds: 500));

        // Reload all requests
        await _loadAndEmitRequests(emit);
      },
    );
  }

  Future<void> _onUpdateAlarmRequest(
    UpdateAlarmRequestEvent event,
    Emitter<AlarmRequestState> emit,
  ) async {
    emit(const AlarmRequestLoading(preserveData: true));

    final result = await updateAlarmRequestUseCase.call(
      UpdateAlarmRequestParams(
        requestId: event.requestId,
        message: event.message,
      ),
    );

    await result.fold(
      (failure) async {
        emit(AlarmRequestError(message: _mapFailureToMessage(failure)));
        // Restore previous state
        if (_cachedSentRequests.isNotEmpty ||
            _cachedReceivedRequests.isNotEmpty) {
          await Future.delayed(const Duration(seconds: 2));
          emit(AlarmRequestsLoaded(
            sentRequests: _cachedSentRequests,
            receivedRequests: _cachedReceivedRequests,
          ));
        }
      },
      (_) async {
        emit(
            const AlarmRequestUpdated(message: 'Request updated successfully'));
        await Future.delayed(const Duration(milliseconds: 500));
        await _loadAndEmitRequests(emit);
      },
    );
  }

  Future<void> _onDeleteAlarmRequest(
    DeleteAlarmRequestEvent event,
    Emitter<AlarmRequestState> emit,
  ) async {
    emit(const AlarmRequestLoading(preserveData: true));

    final result = await deleteAlarmRequestUseCase.call(
      DeleteAlarmRequestParams(requestId: event.requestId),
    );

    await result.fold(
      (failure) async {
        emit(AlarmRequestError(message: _mapFailureToMessage(failure)));
        // Restore previous state
        if (_cachedSentRequests.isNotEmpty ||
            _cachedReceivedRequests.isNotEmpty) {
          await Future.delayed(const Duration(seconds: 2));
          emit(AlarmRequestsLoaded(
            sentRequests: _cachedSentRequests,
            receivedRequests: _cachedReceivedRequests,
          ));
        }
      },
      (_) async {
        emit(
            const AlarmRequestDeleted(message: 'Request deleted successfully'));
        await Future.delayed(const Duration(milliseconds: 500));
        await _loadAndEmitRequests(emit);
      },
    );
  }

  Future<void> _onAcceptRequest(
    AcceptRequestEvent event,
    Emitter<AlarmRequestState> emit,
  ) async {
    emit(const AlarmRequestLoading(preserveData: true));

    final result = await acceptRequestUseCase.call(
      AcceptRequestParams(requestId: event.requestId),
    );

    await result.fold(
      (failure) async {
        emit(AlarmRequestError(message: _mapFailureToMessage(failure)));
        // Restore previous state
        if (_cachedSentRequests.isNotEmpty ||
            _cachedReceivedRequests.isNotEmpty) {
          await Future.delayed(const Duration(seconds: 2));
          emit(AlarmRequestsLoaded(
            sentRequests: _cachedSentRequests,
            receivedRequests: _cachedReceivedRequests,
          ));
        }
      },
      (_) async {
        emit(const RequestAccepted(message: 'Request accepted successfully'));
        await Future.delayed(const Duration(milliseconds: 500));
        await _loadAndEmitRequests(emit);
      },
    );
  }

  Future<void> _onRejectRequest(
    RejectRequestEvent event,
    Emitter<AlarmRequestState> emit,
  ) async {
    emit(const AlarmRequestLoading(preserveData: true));

    final result = await rejectRequestUseCase.call(
      RejectRequestParams(requestId: event.requestId),
    );

    await result.fold(
      (failure) async {
        emit(AlarmRequestError(message: _mapFailureToMessage(failure)));
        // Restore previous state
        if (_cachedSentRequests.isNotEmpty ||
            _cachedReceivedRequests.isNotEmpty) {
          await Future.delayed(const Duration(seconds: 2));
          emit(AlarmRequestsLoaded(
            sentRequests: _cachedSentRequests,
            receivedRequests: _cachedReceivedRequests,
          ));
        }
      },
      (_) async {
        emit(const RequestRejected(message: 'Request rejected successfully'));
        await Future.delayed(const Duration(milliseconds: 500));
        await _loadAndEmitRequests(emit);
      },
    );
  }

  Future<void> _onRefreshRequests(
    RefreshRequestsEvent event,
    Emitter<AlarmRequestState> emit,
  ) async {
    await _loadAndEmitRequests(emit);
  }

  // Helper method to load and emit requests
  Future<void> _loadAndEmitRequests(Emitter<AlarmRequestState> emit) async {
    final sentResult = await getSentRequestsUseCase.call();
    final receivedResult = await getReceivedRequestsUseCase.call();

    final failure = sentResult.fold((l) => l, (_) => null) ??
        receivedResult.fold((l) => l, (_) => null);

    if (failure != null) {
      emit(AlarmRequestError(message: _mapFailureToMessage(failure)));
      return;
    }

    _cachedSentRequests = sentResult.getOrElse(() => []);
    _cachedReceivedRequests = receivedResult.getOrElse(() => []);

    emit(AlarmRequestsLoaded(
      sentRequests: _cachedSentRequests,
      receivedRequests: _cachedReceivedRequests,
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
