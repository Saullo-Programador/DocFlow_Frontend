import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Interceptor para logging detalhado de requisições e respostas
///
/// Útil para debug durante desenvolvimento
/// Pode ser desabilitado em produção
class LoggingInterceptor extends Interceptor {
  final Logger _logger;
  final bool logRequestHeaders;
  final bool logResponseHeaders;
  final bool logRequestBody;
  final bool logResponseBody;

  LoggingInterceptor({
    required Logger logger,
    this.logRequestHeaders = true,
    this.logResponseHeaders = false,
    this.logRequestBody = true,
    this.logResponseBody = true,
  }) : _logger = logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.i('╔╣ ${'═' * 40} ╠╗');
    _logger.i('║ REQUEST ║ ${options.method.toUpperCase()} ║ ${options.path}');
    _logger.i('╠${'═' * 42}╣');

    // Log headers
    if (logRequestHeaders && options.headers.isNotEmpty) {
      _logger.i('║ Headers:');
      options.headers.forEach((key, value) {
        // Não logar token completo, apenas indicar presença
        final displayValue = key.toLowerCase() == 'authorization'
            ? 'Bearer ***${value.toString().substring(value.toString().length - 8)}'
            : value;
        _logger.i('║   $key: $displayValue');
      });
    }

    // Log query parameters
    if (options.queryParameters.isNotEmpty) {
      _logger.i('║ Query Parameters:');
      options.queryParameters.forEach((key, value) {
        _logger.i('║   $key: $value');
      });
    }

    // Log body
    if (logRequestBody && options.data != null) {
      _logger.i('║ Body:');
      if (options.data is FormData) {
        final formData = options.data as FormData;
        _logger.i('║   [FormData]');
        for (var field in formData.fields) {
          _logger.i('║   ${field.key}: ${field.value}');
        }
        for (var file in formData.files) {
          _logger.i('║   ${file.key}: ${file.value.filename} (${file.value.length} bytes)');
        }
      } else {
        _logger.i('║   ${options.data}');
      }
    }

    _logger.i('╚${'═' * 42}╝');

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final statusCode = response.statusCode;
    final statusEmoji = _getStatusEmoji(statusCode);

    _logger.i('╔╣ ${'═' * 40} ╠╗');
    _logger.i('║ RESPONSE ║ $statusEmoji $statusCode ║ ${response.requestOptions.path}');
    _logger.i('╠${'═' * 42}╣');

    // Log response headers
    if (logResponseHeaders && response.headers.map.isNotEmpty) {
      _logger.i('║ Headers:');
      response.headers.map.forEach((key, values) {
        _logger.i('║   $key: ${values.join(', ')}');
      });
    }

    // Log response body
    if (logResponseBody && response.data != null) {
      _logger.i('║ Body:');
      final body = response.data is Map || response.data is List
          ? _formatJson(response.data)
          : response.data.toString();

      // Limitar tamanho do log
      final lines = body.split('\n');
      final maxLines = 50;
      for (var i = 0; i < lines.length && i < maxLines; i++) {
        _logger.i('║   ${lines[i]}');
      }
      if (lines.length > maxLines) {
        _logger.i('║   ... (${lines.length - maxLines} linhas ocultas)');
      }
    }

    _logger.i('╚${'═' * 42}╝');

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode ?? 'ERROR';

    _logger.e('╔╣ ${'═' * 40} ╠╗');
    _logger.e('║ ERROR ║ ❌ $statusCode ║ ${err.requestOptions.path}');
    _logger.e('╠${'═' * 42}╣');
    _logger.e('║ Type: ${err.type}');
    _logger.e('║ Message: ${err.message}');

    if (err.response?.data != null) {
      _logger.e('║ Response Data:');
      _logger.e('║   ${err.response?.data}');
    }

    _logger.e('╚${'═' * 42}╝');

    handler.next(err);
  }

  String _getStatusEmoji(int? statusCode) {
    if (statusCode == null) return '❓';
    if (statusCode >= 200 && statusCode < 300) return '✅';
    if (statusCode >= 300 && statusCode < 400) return '🔀';
    if (statusCode >= 400 && statusCode < 500) return '⚠️';
    return '❌';
  }

  String _formatJson(dynamic json) {
    if (json is Map) {
      return json.entries
          .map((e) => '  "${e.key}": ${_formatValue(e.value)}')
          .join(',\n');
    } else if (json is List) {
      return json.asMap().entries
          .map((e) => '  [${e.key}]: ${_formatValue(e.value)}')
          .join(',\n');
    }
    return json.toString();
  }

  String _formatValue(dynamic value) {
    if (value is String) return '"$value"';
    if (value is Map) return '{...}';
    if (value is List) return '[...(${value.length} items)]';
    return value.toString();
  }
}
