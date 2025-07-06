import 'package:equatable/equatable.dart';

import '../../../domain/entities/user.dart';

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

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
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
