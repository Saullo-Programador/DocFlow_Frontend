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
  const ConnectionException({String message = 'Erro de conexão'})
      : super(message: message);
}

/// Erro de timeout
class TimeoutException extends ApiException {
  const TimeoutException({String message = 'Tempo de requisição excedido'})
      : super(message: message);
}

/// Erro 400 - Bad Request
class BadRequestException extends ApiException {
  const BadRequestException({
    String message = 'Requisição inválida',
    dynamic data,
  }) : super(message: message, statusCode: 400, data: data);
}

/// Erro 401 - Unauthorized
class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    String message = 'Não autorizado',
    dynamic data,
  }) : super(message: message, statusCode: 401, data: data);
}

/// Erro 403 - Forbidden
class ForbiddenException extends ApiException {
  const ForbiddenException({
    String message = 'Acesso negado',
    dynamic data,
  }) : super(message: message, statusCode: 403, data: data);
}

/// Erro 404 - Not Found
class NotFoundException extends ApiException {
  const NotFoundException({
    String message = 'Recurso não encontrado',
    dynamic data,
  }) : super(message: message, statusCode: 404, data: data);
}

/// Erro 409 - Conflict
class ConflictException extends ApiException {
  const ConflictException({
    String message = 'Conflito de dados',
    dynamic data,
  }) : super(message: message, statusCode: 409, data: data);
}

/// Erro 422 - Unprocessable Entity
class ValidationException extends ApiException {
  const ValidationException({
    String message = 'Dados inválidos',
    dynamic data,
  }) : super(message: message, statusCode: 422, data: data);
}

/// Erro 500+ - Server Error
class ServerException extends ApiException {
  const ServerException({
    String message = 'Erro no servidor',
    int statusCode = 500,
    dynamic data,
  }) : super(message: message, statusCode: statusCode, data: data);
}

/// Erro desconhecido
class UnknownApiException extends ApiException {
  const UnknownApiException({
    String message = 'Erro desconhecido',
    dynamic data,
  }) : super(message: message, data: data);
}
