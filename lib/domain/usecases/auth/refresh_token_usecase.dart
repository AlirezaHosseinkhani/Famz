import '../../repositories/auth_repository.dart';

class RefreshTokenUseCase {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  // Future<Either<Failure, TokenModel>> call() async {
  // return await repository.refreshToken();
  // }
}
