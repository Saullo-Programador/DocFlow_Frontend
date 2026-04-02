import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/users_repository.dart';

/// Caso de uso: Obter perfil do usuário atual
class GetCurrentUserProfileUseCase {
  final UsersRepository _repository;

  GetCurrentUserProfileUseCase(this._repository);

  Future<Either<Failure, UserProfileEntity>> call() {
    return _repository.getCurrentUser();
  }
}

/// Caso de uso: Listar todos os usuários (admin)
class GetAllUsersUseCase {
  final UsersRepository _repository;

  GetAllUsersUseCase(this._repository);

  Future<Either<Failure, List<UserProfileEntity>>> call() {
    return _repository.getAllUsers();
  }
}

/// Caso de uso: Atualizar perfil
class UpdateProfileUseCase {
  final UsersRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<Either<Failure, UserProfileEntity>> call({
    String? name,
    String? avatarUrl,
  }) {
    return _repository.updateProfile(name: name, avatarUrl: avatarUrl);
  }
}

/// Caso de uso: Alterar senha
class ChangePasswordUseCase {
  final UsersRepository _repository;

  ChangePasswordUseCase(this._repository);

  Future<Either<Failure, void>> call(String currentPassword, String newPassword) {
    return _repository.changePassword(currentPassword, newPassword);
  }
}

/// Caso de uso: Contagem de usuários
class GetUsersCountUseCase {
  final UsersRepository _repository;

  GetUsersCountUseCase(this._repository);

  Future<Either<Failure, int>> call() {
    return _repository.getUsersCount();
  }
}
