// lib/presentation/bloc/auth/auth_event.dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckStatusEvent extends AuthEvent {}

class AuthCheckExistenceEvent extends AuthEvent {
  final String emailOrPhone;

  const AuthCheckExistenceEvent({required this.emailOrPhone});

  @override
  List<Object?> get props => [emailOrPhone];
}

class AuthLoginEvent extends AuthEvent {
  final String emailOrPhone;
  final String password;

  const AuthLoginEvent({
    required this.emailOrPhone,
    required this.password,
  });

  @override
  List<Object?> get props => [emailOrPhone, password];
}

class AuthRegisterEvent extends AuthEvent {
  final String emailOrPhone;
  final String password;
  final String username;

  const AuthRegisterEvent({
    required this.emailOrPhone,
    required this.password,
    required this.username,
  });

  @override
  List<Object?> get props => [emailOrPhone, password, username];
}

class AuthLogoutEvent extends AuthEvent {}

class AuthRefreshTokenEvent extends AuthEvent {}

class AuthClearErrorEvent extends AuthEvent {}
