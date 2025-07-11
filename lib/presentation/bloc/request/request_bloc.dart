import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/alarm_request/accept_request_usecase.dart';
import '../../../domain/usecases/alarm_request/create_alarm_request_usecase.dart';
import '../../../domain/usecases/alarm_request/delete_alarm_request_usecase.dart';
import '../../../domain/usecases/alarm_request/get_received_requests_usecase.dart';
import '../../../domain/usecases/alarm_request/get_sent_requests_usecase.dart';
import '../../../domain/usecases/alarm_request/reject_request_usecase.dart';
import 'request_event.dart';
import 'request_state.dart';

class RequestBloc extends Bloc<RequestEvent, RequestState> {
  final GetSentRequestsUseCase getSentRequestsUseCase;
  final GetReceivedRequestsUseCase getReceivedRequestsUseCase;
  final CreateAlarmRequestUseCase createAlarmRequestUseCase;
  final AcceptRequestUseCase acceptRequestUseCase;
  final RejectRequestUseCase rejectRequestUseCase;
  final DeleteAlarmRequestUseCase deleteAlarmRequestUseCase;

  RequestBloc({
    required this.getSentRequestsUseCase,
    required this.getReceivedRequestsUseCase,
    required this.createAlarmRequestUseCase,
    required this.acceptRequestUseCase,
    required this.rejectRequestUseCase,
    required this.deleteAlarmRequestUseCase,
  }) : super(RequestInitial()) {
    on<GetSentRequestsRequested>(_onGetSentRequestsRequested);
    on<GetReceivedRequestsRequested>(_onGetReceivedRequestsRequested);
    on<CreateRequestRequested>(_onCreateRequestRequested);
    on<AcceptRequestRequested>(_onAcceptRequestRequested);
    on<RejectRequestRequested>(_onRejectRequestRequested);
    on<DeleteRequestRequested>(_onDeleteRequestRequested);
  }

  Future<void> _onGetSentRequestsRequested(
    GetSentRequestsRequested event,
    Emitter<RequestState> emit,
  ) async {
    emit(RequestLoading());

    final result = await getSentRequestsUseCase();

    result.fold(
      (failure) => emit(RequestError(message: failure.message)),
      (requests) => emit(SentRequestsLoaded(requests: requests)),
    );
  }

  Future<void> _onGetReceivedRequestsRequested(
    GetReceivedRequestsRequested event,
    Emitter<RequestState> emit,
  ) async {
    emit(RequestLoading());

    final result = await getReceivedRequestsUseCase();

    result.fold(
      (failure) => emit(RequestError(message: failure.message)),
      (requests) => emit(ReceivedRequestsLoaded(requests: requests)),
    );
  }

  Future<void> _onCreateRequestRequested(
    CreateRequestRequested event,
    Emitter<RequestState> emit,
  ) async {
    emit(RequestLoading());

    final result = await createAlarmRequestUseCase(
      CreateAlarmRequestParams(
        toUserId: event.toUserId,
        message: event.message,
      ),
    );

    result.fold(
      (failure) => emit(RequestError(message: failure.message)),
      (request) {
        emit(RequestCreated(request: request));
        add(GetSentRequestsRequested());
      },
    );
  }

  Future<void> _onAcceptRequestRequested(
    AcceptRequestRequested event,
    Emitter<RequestState> emit,
  ) async {
    // final result = await acceptRequestUseCase(
    //   AcceptRequestParams(requestId: event.requestId),
    // );
    //
    // result.fold(
    //   (failure) => emit(RequestError(message: failure.message)),
    //   (_) {
    //     emit(RequestAccepted(requestId: event.requestId));
    //     add(GetReceivedRequestsRequested());
    //   },
    // );
  }

  Future<void> _onRejectRequestRequested(
    RejectRequestRequested event,
    Emitter<RequestState> emit,
  ) async {
    // final result = await rejectRequestUseCase(
    //   RejectRequestParams(requestId: event.requestId),
    // );
    //
    // result.fold(
    //   (failure) => emit(RequestError(message: failure.message)),
    //   (_) {
    //     emit(RequestRejected(requestId: event.requestId));
    //     add(GetReceivedRequestsRequested());
    //   },
    // );
  }

  Future<void> _onDeleteRequestRequested(
    DeleteRequestRequested event,
    Emitter<RequestState> emit,
  ) async {
    // final result = await deleteAlarmRequestUseCase(
    //   DeleteAlarmRequestParams(requestId: event.requestId),
    // );
    //
    // result.fold(
    //   (failure) => emit(RequestError(message: failure.message)),
    //   (_) {
    //     emit(RequestDeleted(requestId: event.requestId));
    //     add(GetSentRequestsRequested());
    //   },
    // );
  }
}
