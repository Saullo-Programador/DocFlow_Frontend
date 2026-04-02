import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/exceptions/auth_exception.dart';

/// Interface para armazenamento local de dados de autenticação
abstract class AuthLocalDataSource {
  /// Salva o token de acesso de forma segura
  Future<void> saveAccessToken(String token);

  /// Obtém o token de acesso
  Future<String?> getAccessToken();

  /// Salva o refresh token de forma segura
  Future<void> saveRefreshToken(String token);

  /// Obtém o refresh token
  Future<String?> getRefreshToken();

  /// Salva dados do usuário
  Future<void> saveUserData(Map<String, dynamic> userData);

  /// Obtém dados do usuário
  Future<Map<String, dynamic>?> getUserData();

  /// Limpa todos os tokens (logout)
  Future<void> clearTokens();

  /// Verifica se usuário está logado
  Future<bool> isLoggedIn();
}

/// Implementação usando SecureStorage (tokens) + SharedPreferences (dados)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _sharedPreferences;

  // Chaves de armazenamento
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  AuthLocalDataSourceImpl({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences sharedPreferences,
  })  : _secureStorage = secureStorage,
        _sharedPreferences = sharedPreferences;

  @override
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: _accessTokenKey, value: token);
  }

  @override
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    // Salvar como JSON string no SharedPreferences
    await _sharedPreferences.setString(_userDataKey, userData.toString());
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    final data = _sharedPreferences.getString(_userDataKey);
    if (data == null) return null;
    // TODO: Implementar parsing adequado se salvar como JSON
    return {};
  }

  @override
  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
      _sharedPreferences.remove(_userDataKey),
    ]);
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
