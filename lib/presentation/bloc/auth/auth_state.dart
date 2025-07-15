import 'package:equatable/equatable.dart';

import '../../../data/models/auth/token_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthVerificationCodeSent extends AuthState {
  final String message;
  final String phoneNumber;

  const AuthVerificationCodeSent({
    required this.message,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [message, phoneNumber];
}

class AuthLogin extends AuthState {
  final String phoneNumber;
  final String password;

  const AuthLogin({
    required this.phoneNumber,
    required this.password,
  });

  @override
  List<Object?> get props => [phoneNumber, password];
}

class AuthAuthenticated extends AuthState {
  final TokenModel token;

  const AuthAuthenticated({required this.token});

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
