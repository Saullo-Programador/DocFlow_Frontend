import 'package:equatable/equatable.dart';
import 'user_entity.dart';

/// Entidade de autenticação (contém token + usuário)
class AuthEntity extends Equatable {
  final String accessToken;
  final String? refreshToken;
  final UserEntity user;

  const AuthEntity({
    required this.accessToken,
    this.refreshToken,
    required this.user,
  });

  /// Verifica se há token válido
  bool get isAuthenticated => accessToken.isNotEmpty;

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}
