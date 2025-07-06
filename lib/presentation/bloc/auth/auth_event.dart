import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckStatusEvent extends AuthEvent {}

class AuthSendVerificationCodeEvent extends AuthEvent {
  final String phoneNumber;

  const AuthSendVerificationCodeEvent({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

class AuthVerifyOtpEvent extends AuthEvent {
  final String phoneNumber;
  final String otpCode;

  const AuthVerifyOtpEvent({
    required this.phoneNumber,
    required this.otpCode,
  });

  @override
  List<Object?> get props => [phoneNumber, otpCode];
}

class AuthRegisterEvent extends AuthEvent {
  final String phoneNumber;
  final String name;
  final String otpCode;

  const AuthRegisterEvent({
    required this.phoneNumber,
    required this.name,
    required this.otpCode,
  });

  @override
  List<Object?> get props => [phoneNumber, name, otpCode];
}

class AuthLogoutEvent extends AuthEvent {}

class AuthRefreshTokenEvent extends AuthEvent {}

class AuthClearErrorEvent extends AuthEvent {}
