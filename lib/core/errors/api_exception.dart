import 'package:equatable/equatable.dart';

/// Classe base para exceções da API
abstract class ApiException extends Equatable implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  List<Object?> get props => [message, statusCode, data];

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Erro de conexão (sem internet, timeout, etc.)
class ConnectionException extends ApiException {
  const ConnectionException({super.message = 'Erro de conexão'});
}

/// Erro de timeout
class TimeoutException extends ApiException {
  const TimeoutException({super.message = 'Tempo de requisição excedido'});
}

/// Erro 400 - Bad Request
class BadRequestException extends ApiException {
  const BadRequestException({
    super.message = 'Requisição inválida',
    super.data,
  }) : super(statusCode: 400);
}

/// Erro 401 - Unauthorized
class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Não autorizado',
    super.data,
  }) : super(statusCode: 401);
}

/// Erro 403 - Forbidden
class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'Acesso negado',
    super.data,
  }) : super(statusCode: 403);
}

/// Erro 404 - Not Found
class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'Recurso não encontrado',
    super.data,
  }) : super(statusCode: 404);
}

/// Erro 409 - Conflict
class ConflictException extends ApiException {
  const ConflictException({
    super.message = 'Conflito de dados',
    super.data,
  }) : super(statusCode: 409);
}

/// Erro 422 - Unprocessable Entity
class ValidationException extends ApiException {
  const ValidationException({
    super.message = 'Dados inválidos',
    super.data,
  }) : super(statusCode: 422);
}

/// Erro 500+ - Server Error
class ServerException extends ApiException {
  const ServerException({
    super.message = 'Erro no servidor',
    super.statusCode = 500,
    super.data,
  });
}

/// Erro desconhecido
class UnknownApiException extends ApiException {
  const UnknownApiException({
    super.message = 'Erro desconhecido',
    super.data,
  });
}
