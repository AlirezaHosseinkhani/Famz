import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/auth/token_model.dart';
import '../../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, TokenModel>> call(
      String phoneNumber, String password) async {
    return await repository.login(phoneNumber, password);
  }
}
