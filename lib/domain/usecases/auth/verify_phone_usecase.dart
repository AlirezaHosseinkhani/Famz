import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/auth/token_model.dart';
import '../../repositories/auth_repository.dart';

class VerifyPhoneUseCase {
  final AuthRepository repository;

  VerifyPhoneUseCase(this.repository);

  Future<Either<Failure, TokenModel>> call(VerifyPhoneParams params) async {
    // return await repository.login(params.phoneNumber, params.otpCode);
    return await repository.login("user@example.com", "password123");
  }
}

class VerifyPhoneParams {
  final String phoneNumber;
  final String otpCode;

  VerifyPhoneParams({
    required this.phoneNumber,
    required this.otpCode,
  });
}
