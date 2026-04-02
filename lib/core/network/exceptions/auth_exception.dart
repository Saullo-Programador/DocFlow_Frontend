/// Exceções específicas de autenticação
abstract class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Token não encontrado
class TokenNotFoundException extends AuthException {
  const TokenNotFoundException() : super('Token não encontrado');
}

/// Token expirado
class TokenExpiredException extends AuthException {
  const TokenExpiredException() : super('Token expirado');
}

/// Credenciais inválidas
class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException() : super('Credenciais inválidas');
}

/// Usuário já existe
class UserAlreadyExistsException extends AuthException {
  const UserAlreadyExistsException() : super('Usuário já existe');
}

/// Usuário não encontrado
class UserNotFoundException extends AuthException {
  const UserNotFoundException() : super('Usuário não encontrado');
}

/// Código de verificação inválido
class InvalidVerificationCodeException extends AuthException {
  const InvalidVerificationCodeException() : super('Código de verificação inválido');
}

/// Código de verificação expirado
class VerificationCodeExpiredException extends AuthException {
  const VerificationCodeExpiredException() : super('Código de verificação expirado');
}
