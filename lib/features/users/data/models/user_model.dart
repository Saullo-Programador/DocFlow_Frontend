import '../../domain/entities/user_profile_entity.dart';

/// Modelo de usuário da API
class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isAdmin;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
    this.isAdmin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString(),
      avatarUrl: json['avatarUrl']?.toString() ?? json['avatar']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      isAdmin: json['isAdmin'] as bool? ?? json['role'] == 'admin',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (name != null) 'name': name,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (isAdmin != null) 'isAdmin': isAdmin,
    };
  }

  /// Converte para entidade de domínio
  UserProfileEntity toEntity() {
    return UserProfileEntity(
      id: id,
      email: email,
      name: name,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
      isAdmin: isAdmin ?? false,
    );
  }
}
