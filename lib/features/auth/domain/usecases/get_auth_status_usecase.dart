import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: Verificar se está logado
class IsLoggedInUseCase {
  final AuthRepository _repository;

  IsLoggedInUseCase(this._repository);

  Future<Either<Failure, bool>> call() {
    return _repository.isLoggedIn();
  }
}

/// Caso de uso: Obter usuário atual
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<Either<Failure, UserEntity?>> call() {
    return _repository.getCurrentUser();
  }
}
