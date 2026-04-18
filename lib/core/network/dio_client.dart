import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/api_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import '../errors/api_exception.dart';

/// Cliente HTTP base configurado com Dio
///
/// Fornece:
/// - Configuração centralizada de timeouts
/// - Interceptors para autenticação e logging
/// - Tratamento padronizado de erros
class DioClient {
  late final Dio _dio;
  final Logger _logger;

  DioClient({
    AuthInterceptor? authInterceptor,
    required Logger logger,
    String? baseUrl,
  }) : _logger = logger {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
        headers: {
          ApiConstants.contentTypeHeader: ApiConstants.applicationJson,
          ApiConstants.acceptHeader: ApiConstants.applicationJson,
        },
      ),
    );

    // Adicionar interceptors
    final interceptors = <Interceptor>[
      LoggingInterceptor(logger: _logger),
    ];

    if (authInterceptor != null) {
      interceptors.insert(0, authInterceptor);
    }

    _dio.interceptors.addAll(interceptors);
  }

  /// Getter para acesso direto ao Dio (se necessário)
  Dio get dio => _dio;

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Upload de arquivo (multipart/form-data)
  Future<Response<T>> upload<T>(
    String path, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    void Function(int sent, int total)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: Options(
          contentType: 'multipart/form-data',
        ),
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Download de arquivo
  Future<Response<List<int>>> download(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<List<int>>(
        path,
        queryParameters: queryParameters,
        options: Options(
          responseType: ResponseType.bytes,
        ),
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Converte DioException em ApiException
  ApiException _handleDioError(DioException error) {
    _logger.e('DioError: ${error.type}', error: error);

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException();
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        if (error.error.toString().contains('SocketException')) {
          return const ConnectionException();
        }
        return UnknownApiException(
          message: error.message ?? 'Erro desconhecido',
          data: error.response?.data,
        );
      case DioExceptionType.badResponse:
        return _handleResponseError(
          error.response?.statusCode,
          error.response?.data,
        );
      case DioExceptionType.cancel:
        return const ConnectionException(message: 'Requisição cancelada');
      case DioExceptionType.badCertificate:
        return const ConnectionException(message: 'Erro de certificado SSL');
    }
  }

  /// Converte status code em ApiException específica
  ApiException _handleResponseError(int? statusCode, dynamic data) {
    final message = _extractMessage(data);

    switch (statusCode) {
      case 400:
        return BadRequestException(message: message, data: data);
      case 401:
        return UnauthorizedException(message: message, data: data);
      case 403:
        return ForbiddenException(message: message, data: data);
      case 404:
        return NotFoundException(message: message, data: data);
      case 409:
        return ConflictException(message: message, data: data);
      case 422:
        return ValidationException(message: message, data: data);
      default:
        if (statusCode != null && statusCode >= 500) {
          return ServerException(message: message, statusCode: statusCode, data: data);
        }
        return UnknownApiException(message: message, data: data);
    }
  }

  /// Extrai mensagem de erro da resposta
  String _extractMessage(dynamic data) {
    if (data == null) return 'Erro desconhecido';

    if (data is Map) {
      // Tentar extrair de campos comuns
      final possibleFields = ['message', 'error', 'detail', 'msg', 'description'];
      for (final field in possibleFields) {
        if (data.containsKey(field) && data[field] != null) {
          return data[field].toString();
        }
      }
    }

    return data.toString();
  }
}
