// lib/domain/usecases/auth/check_existence_usecase.dart
import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/auth/check_existence_response_model.dart';
import '../../repositories/auth_repository.dart';

class CheckExistenceUseCase {
  final AuthRepository repository;

  CheckExistenceUseCase(this.repository);

  Future<Either<Failure, CheckExistenceResponseModel>> call(
      String emailOrPhone) async {
    return await repository.checkExistence(emailOrPhone);
  }
}
