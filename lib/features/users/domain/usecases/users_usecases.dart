import 'package:dartz/dartz.dart';
import 'package:manege_doc/core/constants/type_role.dart';
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

/// Caso de uso: Deletar usuário (admin)
class DeleteUserUseCase {
  final UsersRepository _repository;

  DeleteUserUseCase(this._repository);

  Future<Either<Failure, void>> call(String userId) {
    return _repository.deleteUser(userId);
  }
}

/// Caso de uso: Atualizar perfil de usuário (admin)
class UpdateUserUseCase {
  final UsersRepository _repository;

  UpdateUserUseCase(this._repository);

  Future<Either<Failure, void>> call(
    String id, {
    String? name,
    TypeRole? role
  }) {
    return _repository.updateUser(id, name: name, role: role);
  }
}
