import 'dart:async';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../constants/api_constants.dart';
import '../../errors/api_exception.dart';

/// Interceptor responsável por:
/// 1. Adicionar token JWT em todas as requisições autenticadas
/// 2. Atualizar token quando necessário
/// 3. Fazer logout em caso de 401
class AuthInterceptor extends Interceptor {
  final AuthLocalDataSource _localDataSource;
  final AuthRemoteDataSource _remoteDataSource;
  final Logger _logger;

  // Lista de paths que não precisam de autenticação
  final List<String> _publicPaths = [
    '/auth/register',
    '/auth/login',
    '/auth/refresh',
    '/auth/forgot-password',
    '/auth/reset-password',
    '/auth/verify-code',
  ];

  // Flag para evitar múltiplas tentativas de refresh simultâneas
  bool _isRefreshing = false;

  // Queue de requisições pendentes durante o refresh
  final List<Completer<void>> _pendingRequests = [];

  AuthInterceptor({
    required AuthLocalDataSource localDataSource,
    required AuthRemoteDataSource remoteDataSource,
    required Logger logger,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _logger = logger;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Verificar se é um endpoint público
    if (_isPublicPath(options.path)) {
      handler.next(options);
      return;
    }

    try {
      // Tentar obter token do storage seguro
      final token = await _localDataSource.getAccessToken();

      if (token != null && token.isNotEmpty) {
        options.headers[ApiConstants.authorizationHeader] =
            '${ApiConstants.bearerPrefix} $token';
        _logger.d('Token adicionado à requisição: ${options.path}');
      } else {
        _logger.w('Requisição sem token: ${options.path}');
      }
    } catch (e) {
      _logger.e('Erro ao obter token: $e');
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Tratar erro 401 - Unauthorized
    if (err.response?.statusCode == 401) {
      _logger.w('Erro 401 detectado: ${err.requestOptions.path}');

      // Verificar se não é uma requisição de login (para evitar loop)
      if (_isAuthPath(err.requestOptions.path)) {
        _logger.e('Falha de autenticação em endpoint de auth');
        await _handleLogout();
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const UnauthorizedException(message: 'Falha de autenticação'),
          ),
        );
        return;
      }

      // Tentar refresh do token
      if (!_isRefreshing) {
        _isRefreshing = true;

        try {
          final refreshed = await _refreshToken();

          if (refreshed) {
            _logger.i('Token refreshado com sucesso');

            // Completar requisições pendentes
            for (var completer in _pendingRequests) {
              completer.complete();
            }
            _pendingRequests.clear();

            // Retry da requisição original
            final requestOptions = err.requestOptions;
            final newToken = await _localDataSource.getAccessToken();

            requestOptions.headers[ApiConstants.authorizationHeader] =
                '${ApiConstants.bearerPrefix} $newToken';

            // Retry com novo token usando Dio configurado corretamente
            final dio = Dio(
              BaseOptions(
                baseUrl: err.requestOptions.baseUrl,
                connectTimeout: err.requestOptions.connectTimeout,
                receiveTimeout: err.requestOptions.receiveTimeout,
                sendTimeout: err.requestOptions.sendTimeout,
                headers: err.requestOptions.headers,
              ),
            );
            final response = await dio.fetch(requestOptions);

            _isRefreshing = false;
            handler.resolve(response);
            return;
          } else {
            _logger.e('Falha ao refreshar token');
            await _handleLogout();
          }
        } catch (e) {
          _logger.e('Erro durante refresh: $e');
          await _handleLogout();
        } finally {
          _isRefreshing = false;
          _pendingRequests.clear();
        }
      } else {
        // Aguardar refresh em andamento
        final completer = Completer<void>();
        _pendingRequests.add(completer);
        await completer.future;

        // Retry com novo token
        final requestOptions = err.requestOptions;
        final newToken = await _localDataSource.getAccessToken();
        requestOptions.headers[ApiConstants.authorizationHeader] =
            '${ApiConstants.bearerPrefix} $newToken';

        // Retry com novo token usando Dio configurado corretamente
        final dio = Dio(
          BaseOptions(
            baseUrl: err.requestOptions.baseUrl,
            connectTimeout: err.requestOptions.connectTimeout,
            receiveTimeout: err.requestOptions.receiveTimeout,
            sendTimeout: err.requestOptions.sendTimeout,
            headers: err.requestOptions.headers,
          ),
        );
        final response = await dio.fetch(requestOptions);
        handler.resolve(response);
        return;
      }
    }

    handler.next(err);
  }

  /// Verifica se o path é público (não precisa de auth)
  bool _isPublicPath(String path) {
    return _publicPaths.any((publicPath) =>
        path.toLowerCase().contains(publicPath.toLowerCase()));
  }

  /// Verifica se é um endpoint de autenticação
  bool _isAuthPath(String path) {
    return path.toLowerCase().contains('/auth/');
  }

  /// Tenta fazer refresh do token chamando a API
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _localDataSource.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        _logger.w('Nenhum refresh token disponível');
        return false;
      }

      _logger.i('Chamando API para refresh do token');

      // Chamar API de refresh
      final authResponse = await _remoteDataSource.refreshToken(refreshToken);

      // Salvar novos tokens
      await _localDataSource.saveAccessToken(authResponse.accessToken);
      if (authResponse.refreshToken != null) {
        await _localDataSource.saveRefreshToken(authResponse.refreshToken!);
      }

      _logger.i('Token atualizado com sucesso');  
      return true;
    } catch (e) {
      _logger.e('Erro ao fazer refresh do token: $e');
      return false;
    }
  }

  /// Realiza logout limpando os tokens
  Future<void> _handleLogout() async {
    try {
      await _localDataSource.clearTokens();
      _logger.i('Tokens limpos após erro de autenticação');

      // Notificar app sobre logout (via event bus ou similar)
      // Implementar notificação para redirecionar para tela de login
    } catch (e) {
      _logger.e('Erro ao limpar tokens: $e');
    }
  }
}
