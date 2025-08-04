import 'package:dartz/dartz.dart';
import 'package:famz/data/models/auth/token_model.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';

class RegisterParams {
  final String phoneNumber;
  final String name;
  final String otpCode;

  RegisterParams({
    required this.phoneNumber,
    required this.name,
    required this.otpCode,
  });
}

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, TokenModel>> call(RegisterParams params) async {
    return await repository.register(
      params.phoneNumber,
      params.name,
      params.otpCode,
    );
  }
}
