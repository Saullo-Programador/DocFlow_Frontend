import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: Recuperação de senha
class ForgotPasswordUseCase {
  final AuthRepository _repository;

  ForgotPasswordUseCase(this._repository);

  Future<Either<Failure, void>> call(String email) {
    return _repository.forgotPassword(email);
  }
}

/// Caso de uso: Verificar código
class VerifyCodeUseCase {
  final AuthRepository _repository;

  VerifyCodeUseCase(this._repository);

  Future<Either<Failure, void>> call(String email, String code) {
    return _repository.verifyCode(email, code);
  }
}

/// Caso de uso: Resetar senha
class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  Future<Either<Failure, void>> call(
    String email,
    String code,
    String newPassword,
  ) {
    return _repository.resetPassword(email, code, newPassword);
  }
}
