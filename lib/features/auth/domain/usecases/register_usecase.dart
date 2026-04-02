import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: Registro
class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<Either<Failure, AuthEntity>> call(
    String email,
    String password, {
    String? name,
  }) {
    return _repository.register(email, password, name: name);
  }
}
