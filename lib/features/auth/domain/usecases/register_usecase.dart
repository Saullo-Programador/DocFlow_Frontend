import 'package:dartz/dartz.dart';
import 'package:manege_doc/core/constants/type_role.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: Registro
class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<Either<Failure, AuthEntity>> call(
    String email,
    TypeRole role,
    String password, {
    String? name,
  }) {
    return _repository.register(email, role, password, name: name);
  }
}

