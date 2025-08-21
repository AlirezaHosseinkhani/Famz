// lib/presentation/bloc/auth/auth_state.dart
import 'package:equatable/equatable.dart';

import '../../../data/models/auth/check_existence_response_model.dart';
import '../../../data/models/auth/token_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthExistenceChecked extends AuthState {
  final CheckExistenceResponseModel result;
  final String emailOrPhone;

  const AuthExistenceChecked({
    required this.result,
    required this.emailOrPhone,
  });

  @override
  List<Object?> get props => [result, emailOrPhone];
}

class AuthAuthenticated extends AuthState {
  final TokenModel token;

  const AuthAuthenticated({required this.token});

  @override
  List<Object?> get props => [token];
}

class AuthRegistrationSuccess extends AuthState {
  final TokenModel token;

  const AuthRegistrationSuccess({required this.token});

  @override
  List<Object?> get props => [token];
}

class AuthError extends AuthState {
  final String message;
  final String? code;

  const AuthError({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

class AuthNetworkError extends AuthState {
  final String message;

  const AuthNetworkError({required this.message});

  @override
  List<Object?> get props => [message];
}
