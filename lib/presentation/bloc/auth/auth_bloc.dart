// lib/presentation/bloc/auth/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../data/models/auth/token_model.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/auth/check_existence_usecase.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';
import '../../../domain/usecases/auth/refresh_token_usecase.dart';
import '../../../domain/usecases/auth/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckExistenceUseCase checkExistenceUseCase;
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final RefreshTokenUseCase refreshTokenUseCase;
  final AuthRepository authRepository;
  final SecureStorage secureStorage;

  AuthBloc({
    required this.checkExistenceUseCase,
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.refreshTokenUseCase,
    required this.authRepository,
    required this.secureStorage,
  }) : super(AuthInitial()) {
    on<AuthCheckStatusEvent>(_onCheckStatus);
    on<AuthCheckExistenceEvent>(_onCheckExistence);
    on<AuthLoginEvent>(_onLogin);
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
        if (isLoggedIn && accessToken != null && refreshToken != null) {
          final token = TokenModel(access: accessToken, refresh: refreshToken);
          emit(AuthAuthenticated(token: token));
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onCheckExistence(
    AuthCheckExistenceEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await checkExistenceUseCase(event.emailOrPhone);
    result.fold(
      (failure) {
        if (failure is NetworkFailure) {
          emit(AuthNetworkError(message: failure.message));
        } else {
          emit(AuthError(message: failure.message, code: failure.code));
        }
      },
      (existenceResult) {
        emit(AuthExistenceChecked(
          result: existenceResult,
          emailOrPhone: event.emailOrPhone,
        ));
      },
    );
  }

  Future<void> _onLogin(
    AuthLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await loginUseCase(event.emailOrPhone, event.password);
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

    final result = await registerUseCase(RegisterParams(
      emailOrPhone: event.emailOrPhone,
      password: event.password,
      username: event.username,
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
        emit(AuthRegistrationSuccess(token: token));
      },
    );
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
    // Implementation for refresh token
    final refreshToken = await secureStorage.getRefreshToken();
    if (refreshToken != null) {
      final result = await authRepository.refreshToken(refreshToken);
      result.fold(
        (failure) => emit(AuthUnauthenticated()),
        (token) => emit(AuthAuthenticated(token: token)),
      );
    } else {
      emit(AuthUnauthenticated());
    }
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
