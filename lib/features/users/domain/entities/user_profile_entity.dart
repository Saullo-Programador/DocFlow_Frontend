import 'package:equatable/equatable.dart';

/// Entidade de perfil de usuário
class UserProfileEntity extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final DateTime? createdAt;
  final bool isAdmin;

  const UserProfileEntity({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    this.createdAt,
    this.isAdmin = false,
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
  List<Object?> get props => [id, email, name, avatarUrl, createdAt, isAdmin];

  UserProfileEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    DateTime? createdAt,
    bool? isAdmin,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
