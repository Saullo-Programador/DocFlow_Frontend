import 'package:dartz/dartz.dart';
import 'package:manege_doc/core/constants/type_role.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_entity.dart';
import '../entities/user_entity.dart';

/// Interface do repositório de autenticação
abstract class AuthRepository {
  /// Realiza login com nome de usuário e senha
  Future<Either<Failure, AuthEntity>> login(String name, String password);

  /// Registra novo usuário
  Future<Either<Failure, AuthEntity>> register(
    String email,
    TypeRole role,
    String password, {
    String? name,
  });

  /// Faz logout
  Future<Either<Failure, void>> logout();

  /// Verifica se usuário está logado
  Future<Either<Failure, bool>> isLoggedIn();

  /// Obtém usuário atual logado
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Solicita recuperação de senha
  Future<Either<Failure, void>> forgotPassword(String email);

  /// Verifica código de recuperação
  Future<Either<Failure, void>> verifyCode(String email, String code);

  /// Reseta senha
  Future<Either<Failure, void>> resetPassword(
    String email,
    String code,
    String newPassword,
  );
}
