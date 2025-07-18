import 'package:famz/data/models/auth/token_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';
import '../../../domain/usecases/auth/refresh_token_usecase.dart';
import '../../../domain/usecases/auth/register_usecase.dart';
import '../../../domain/usecases/auth/verify_phone_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final VerifyPhoneUseCase verifyPhoneUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final RefreshTokenUseCase refreshTokenUseCase;
  final AuthRepository authRepository;
  final SecureStorage secureStorage;

  AuthBloc({
    required this.loginUseCase,
    required this.verifyPhoneUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.refreshTokenUseCase,
    required this.authRepository,
    required this.secureStorage,
  }) : super(AuthInitial()) {
    on<AuthCheckStatusEvent>(_onCheckStatus);
    on<AuthSendVerificationCodeEvent>(_onSendVerificationCode);
    on<AuthLoginEvent>(_onLogin);
    on<AuthVerifyOtpEvent>(_onVerifyOtp);
    on<AuthRegisterEvent>(_onRegister);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthRefreshTokenEvent>(_onRefreshToken);
    on<AuthClearErrorEvent>(_onClearError);
  }

  Future<void> _onCheckStatus(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final isLoggedInResult = await authRepository.isLoggedIn();
    final accessToken = await secureStorage.getAccessToken();
    final refreshToken = await secureStorage.getRefreshToken();

    await isLoggedInResult.fold(
      (failure) async {
        emit(AuthUnauthenticated());
      },
      (isLoggedIn) async {
        if (isLoggedIn) {
          final token =
              TokenModel(access: accessToken!, refresh: refreshToken!);

          emit(AuthAuthenticated(token: token));
          // final userResult = await authRepository.getCurrentUser();
          // userResult.fold(
          //   (failure) {
          //     if (failure is AuthFailure) {
          //       // Token might be expired, try refreshing
          //       add(AuthRefreshTokenEvent());
          //     } else {
          //       emit(AuthUnauthenticated());
          //     }
          //   },
          //   (token) {
          //     if (token != null) {
          //       emit(AuthAuthenticated(token: token));
          //     } else {
          //       emit(AuthUnauthenticated());
          //     }
          //   },
          // );
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onSendVerificationCode(
    AuthSendVerificationCodeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // final result = await loginUseCase(event.phoneNumber);
    // result.fold(
    //   (failure) {
    //     if (failure is NetworkFailure) {
    //       emit(AuthNetworkError(message: failure.message));
    //     } else {
    //       emit(AuthError(message: failure.message, code: failure.code));
    //     }
    //   },
    // (message) {
    emit(AuthVerificationCodeSent(
      message: "message",
      phoneNumber: event.phoneNumber,
    ));
    // },
    // );
  }

  Future<void> _onLogin(
    AuthLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await loginUseCase(event.phoneNumber, event.password);
    result.fold(
      (failure) {
        if (failure is NetworkFailure) {
          emit(AuthNetworkError(message: failure.message));
        } else {
          emit(AuthError(message: failure.message, code: failure.code));
        }
      },
      // (message) {
      //   emit(AuthVerificationCodeSent(
      //     message: "message",
      //     phoneNumber: event.phoneNumber,
      //   ));
      // },
      (token) {
        emit(AuthAuthenticated(token: token));
      },
    );
  }

  Future<void> _onVerifyOtp(
    AuthVerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await verifyPhoneUseCase(VerifyPhoneParams(
      phoneNumber: event.phoneNumber,
      otpCode: event.otpCode,
    ));

    result.fold(
      (failure) {
        if (failure is NetworkFailure) {
          emit(AuthNetworkError(message: failure.message));
        } else {
          emit(AuthError(message: failure.message, code: failure.code));
        }
      },
      (token) {
        emit(AuthAuthenticated(token: token));
      },
    );
  }

  Future<void> _onRegister(
    AuthRegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // final result = await registerUseCase(RegisterParams(
    //   phoneNumber: event.phoneNumber,
    //   name: event.name,
    //   otpCode: event.otpCode,
    // ));
    //
    // result.fold(
    //   (failure) {
    //     if (failure is NetworkFailure) {
    //       emit(AuthNetworkError(message: failure.message));
    //     } else {
    //       emit(AuthError(message: failure.message, code: failure.code));
    //     }
    //   },
    //   (user) {
    //     emit(AuthAuthenticated(token: token));
    //   },
    // );
  }

  Future<void> _onLogout(
    AuthLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await logoutUseCase();
    result.fold(
      (failure) {
        // Even if logout fails, emit unauthenticated state
        emit(AuthUnauthenticated());
      },
      (_) {
        emit(AuthUnauthenticated());
      },
    );
  }

  Future<void> _onRefreshToken(
    AuthRefreshTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    // final result = await refreshTokenUseCase();
    // result.fold(
    //   (failure) {
    //     emit(AuthUnauthenticated());
    //   },
    //   (user) {
    //     emit(AuthAuthenticated(token: token));
    //   },
    // );
  }

  void _onClearError(
    AuthClearErrorEvent event,
    Emitter<AuthState> emit,
  ) {
    if (state is AuthError || state is AuthNetworkError) {
      emit(AuthUnauthenticated());
    }
  }
}
