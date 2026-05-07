import 'package:manege_doc/core/constants/type_role.dart';

import '../../domain/entities/user_profile_entity.dart';

/// Modelo de usuário da API
class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? password;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final TypeRole? role;
  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.password,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
    this.role,});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString(),
      password: json['password']?.toString(),
      avatarUrl: json['avatarUrl']?.toString() ?? json['avatar']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      role: TypeRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => TypeRole.USER,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (name != null) 'name': name,
      if (password != null) 'password': password,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (role != null) 'role': role!.name,
    };
  }

  /// Converte para entidade de domínio
  UserProfileEntity toEntity() {
    return UserProfileEntity(
      id: id,
      email: email,
      name: name,
      password: password,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
      role: role ?? TypeRole.USER,
    );
  }
}
