import 'package:equatable/equatable.dart';
import 'package:manege_doc/core/constants/type_role.dart';

/// Entidade de perfil de usuário
class UserProfileEntity extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? password;
  final String? avatarUrl;
  final DateTime? createdAt;
  final TypeRole role;

  const UserProfileEntity({
    required this.id,
    required this.email,
    this.name,
    this.password,
    this.avatarUrl,
    this.createdAt,
    this.role = TypeRole.USER,
  });

  String get displayName => name ?? email.split('@').first;

  String get initials {
    final nameParts = displayName.split(' ');
    if (nameParts.length > 1 && nameParts[1].isNotEmpty) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return displayName.substring(0, displayName.length > 1 ? 2 : 1).toUpperCase();
  }

  @override
  List<Object?> get props => [id, email, name, password, avatarUrl, createdAt, role];

  UserProfileEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? password,
    String? avatarUrl,
    DateTime? createdAt,
    TypeRole? role,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      password: password ?? this.password,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
    );
  }
}
