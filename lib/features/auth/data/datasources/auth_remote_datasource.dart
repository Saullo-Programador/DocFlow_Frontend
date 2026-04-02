import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';

/// Interface para fonte de dados remota de autenticação
abstract class AuthRemoteDataSource {
  /// Realiza login
  Future<AuthResponseModel> login(LoginRequestModel request);

  /// Registra novo usuário
  Future<AuthResponseModel> register(RegisterRequestModel request);

  /// Faz logout (opcional - pode ser apenas local)
  Future<void> logout();

  /// Solicita recuperação de senha
  Future<void> forgotPassword(String email);

  /// Verifica código de recuperação
  Future<void> verifyCode(String email, String code);

  /// Reseta senha
  Future<void> resetPassword(String email, String code, String newPassword);

  /// Atualiza token
  Future<AuthResponseModel> refreshToken(String refreshToken);
}

/// Implementação usando Dio
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    final response = await _dioClient.post(
      '${ApiConstants.authBase}/login',
      data: request.toJson(),
    );

    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    final response = await _dioClient.post(
      '${ApiConstants.authBase}/register',
      data: request.toJson(),
    );

    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<void> logout() async {
    // Opcional: chamar endpoint de logout no backend
    // await _dioClient.post('${ApiConstants.authBase}/logout');
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _dioClient.post(
      '${ApiConstants.authBase}/forgot-password',
      data: {'email': email},
    );
  }

  @override
  Future<void> verifyCode(String email, String code) async {
    await _dioClient.post(
      '${ApiConstants.authBase}/verify-code',
      data: {
        'email': email,
        'code': code,
      },
    );
  }

  @override
  Future<void> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    await _dioClient.post(
      '${ApiConstants.authBase}/reset-password',
      data: {
        'email': email,
        'code': code,
        'newPassword': newPassword,
      },
    );
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    final response = await _dioClient.post(
      '${ApiConstants.authBase}/refresh',
      data: {'refreshToken': refreshToken},
    );

    return AuthResponseModel.fromJson(response.data);
  }
}
