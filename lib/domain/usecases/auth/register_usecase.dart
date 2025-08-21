// lib/domain/usecases/auth/register_usecase.dart
import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/auth/token_model.dart';
import '../../repositories/auth_repository.dart';

class RegisterParams {
  final String emailOrPhone;
  final String password;
  final String username;

  RegisterParams({
    required this.emailOrPhone,
    required this.password,
    required this.username,
  });
}

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, TokenModel>> call(RegisterParams params) async {
    return await repository.register(
      params.emailOrPhone,
      params.password,
      params.username,
    );
  }
}
