import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../entities/profile.dart';
import '../../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<Either<Failure, Profile>> call() async {
    return await repository.getProfile();
  }
}
