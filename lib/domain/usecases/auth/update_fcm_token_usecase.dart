import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';

class UpdateFcmTokenUseCase {
  final AuthRepository repository;

  UpdateFcmTokenUseCase(this.repository);

  Future<Either<Failure, void>> call(String fcmToken) async {
    return await repository.updateFcmToken(fcmToken);
  }
}
