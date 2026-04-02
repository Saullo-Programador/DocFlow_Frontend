import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

/// Interface para fonte de dados remota de usuários
abstract class UsersRemoteDataSource {
  /// Obtém usuário atual
  Future<UserModel> getCurrentUser();

  /// Lista todos os usuários (admin)
  Future<List<UserModel>> getAllUsers();

  /// Atualiza perfil do usuário
  Future<UserModel> updateProfile({
    String? name,
    String? avatarUrl,
  });

  /// Muda senha
  Future<void> changePassword(String currentPassword, String newPassword);

  /// Obtém contagem total de usuários
  Future<int> getUsersCount();
}

/// Implementação usando Dio
class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  final DioClient _dioClient;

  UsersRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await _dioClient.get(
      '${ApiConstants.usersBase}/me',
    );

    return UserModel.fromJson(response.data);
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    final response = await _dioClient.get(
      ApiConstants.usersBase,
    );

    final data = response.data as List<dynamic>?;
    return data
            ?.map((json) => UserModel.fromJson(json as Map<String, dynamic>))
            .toList() ??
        [];
  }

  @override
  Future<UserModel> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;

    final response = await _dioClient.put(
      '${ApiConstants.usersBase}/me',
      data: data,
    );

    return UserModel.fromJson(response.data);
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    await _dioClient.put(
      '${ApiConstants.usersBase}/me/password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  @override
  Future<int> getUsersCount() async {
    final response = await _dioClient.get(
      '${ApiConstants.usersBase}/count',
    );

    return response.data['count'] as int? ?? 0;
  }
}
