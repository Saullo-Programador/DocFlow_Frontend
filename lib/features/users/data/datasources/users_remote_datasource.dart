import 'package:manege_doc/core/constants/type_role.dart';

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
  Future<UserModel> updateProfile({String? name, String? avatarUrl});

  /// Muda senha
  Future<void> changePassword(String currentPassword, String newPassword);

  /// Deleta usuário (admin)
  Future<void> deleteUser(String id);

  /// Atualiza usuário (admin)
  Future<UserModel> updateUser(String id, {String? name, TypeRole? role});

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
    final response = await _dioClient.get('${ApiConstants.usersBase}/me');

    return UserModel.fromJson(response.data);
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    final response = await _dioClient.get(ApiConstants.usersBase);

    final data = response.data as List<dynamic>?;
    return data
            ?.map((json) => UserModel.fromJson(json as Map<String, dynamic>))
            .toList() ??
        [];
  }

  @override
  Future<UserModel> updateProfile({String? name, String? avatarUrl}) async {
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
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    await _dioClient.put(
      '${ApiConstants.usersBase}/me/password',
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }

  @override
  Future<int> getUsersCount() async {
    final response = await _dioClient.get('${ApiConstants.usersBase}/count');

    return int.parse(response.data.toString());
  }

  @override
  Future<void> deleteUser(String id) async {
    await _dioClient.delete(
      '${ApiConstants.usersBase}/deleteUser',
      queryParameters: {'userId': id},
    );
  }

  @override
  Future<UserModel> updateUser(
    String id, {
    String? name,
    TypeRole? role,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (role != null) data['role'] = role.toString().split('.').last;

    final response = await _dioClient.put(
      '${ApiConstants.usersBase}/updateUser',
      data: data,
      queryParameters: {'userId': id},
    );

    return UserModel.fromJson(response.data);
  }
}
