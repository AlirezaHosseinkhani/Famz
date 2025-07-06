import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, User>> call(RegisterParams params) async {
    return await repository.register(
        params.phoneNumber, params.name, params.otpCode);
  }
}

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
