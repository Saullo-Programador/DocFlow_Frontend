import 'package:equatable/equatable.dart';
import 'api_exception.dart';

/// Classe base para falhas do domínio
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Falha de servidor (erros da API)
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(super.message, {this.statusCode});

  factory ServerFailure.fromException(ApiException exception) {
    return ServerFailure(
      exception.message,
      statusCode: exception.statusCode,
    );
  }
}

/// Falha de conexão (sem internet)
class ConnectionFailure extends Failure {
  const ConnectionFailure() : super('Erro de conexão. Verifique sua internet.');
}

/// Falha de timeout
class TimeoutFailure extends Failure {
  const TimeoutFailure() : super('Tempo de requisição excedido. Tente novamente.');
}

/// Falha de autenticação
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Falha de cache/storage
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Falha de validação
class ValidationFailure extends Failure {
  final Map<String, dynamic>? errors;

  const ValidationFailure(super.message, {this.errors});
}

/// Falha não esperada
class UnexpectedFailure extends Failure {
  const UnexpectedFailure() : super('Ocorreu um erro inesperado.');
}

/// Falha de recurso não encontrado
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Falha de conflito (recurso já existe)
class ConflictFailure extends Failure {
  const ConflictFailure(super.message);
}
