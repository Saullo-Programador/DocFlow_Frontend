import 'package:equatable/equatable.dart';

/// Entidade de usuário (domínio)
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    this.createdAt,
  });

  String get displayName => name ?? email.split('@').first;

  @override
  List<Object?> get props => [id, email, name, avatarUrl, createdAt];

  /// Cria cópia com novos valores
  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
