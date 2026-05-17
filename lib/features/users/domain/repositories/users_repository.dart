import 'package:dartz/dartz.dart';
import 'package:manege_doc/core/constants/type_role.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_profile_entity.dart';

/// Interface do repositório de usuários
abstract class UsersRepository {
  /// Obtém perfil do usuário atual
  Future<Either<Failure, UserProfileEntity>> getCurrentUser();

  /// Lista todos os usuários (admin)
  Future<Either<Failure, List<UserProfileEntity>>> getAllUsers();

  /// Atualiza perfil do usuário
  Future<Either<Failure, UserProfileEntity>> updateProfile({
    String? name,
    String? avatarUrl,
  });

  /// Muda senha do usuário
  Future<Either<Failure, void>> changePassword(
    String currentPassword,
    String newPassword,
  );

  /// Obtém contagem total de usuários
  Future<Either<Failure, int>> getUsersCount();

  /// Deleta um usuário (admin)
  Future<Either<Failure, void>> deleteUser(String userId);

  /// Atualizar perfil de usuário (admin)
  Future<Either<Failure, void>> updateUser(
    String id,
    {
      String? name,
      TypeRole? role
    }
  );
}
