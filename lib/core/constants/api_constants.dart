/// Constantes da API
///
/// Mover para variáveis de ambiente em produção
class ApiConstants {
  ApiConstants._();

  // Base URL - alterar conforme ambiente
  static const String baseUrl = 'http://localhost:8080';
  static const String apiVersion = 'v1';

  // Endpoints base
  static const String authBase = '/auth';
  static const String documentsBase = '/documents';
  static const String searchBase = '/search';
  static const String usersBase = '/users';
  static const String historyBase = '/history';

  // Timeouts (em milissegundos)
  static const int connectTimeout = 30000; // 30 segundos
  static const int receiveTimeout = 30000; // 30 segundos
  static const int sendTimeout = 30000; // 30 segundos

  // Headers
  static const String authorizationHeader = 'Authorization';
  static const String contentTypeHeader = 'Content-Type';
  static const String acceptHeader = 'Accept';
  static const String bearerPrefix = 'Bearer';

  // Content Types
  static const String applicationJson = 'application/json';
  static const String multipartFormData = 'multipart/form-data';
}
