import 'package:flutter/material.dart';
import 'package:manege_doc/core/constants/type_role.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/usecases/users_usecases.dart';

/// Estados do provider de usuários
enum UsersState {
  initial,
  loading,
  loaded,
  updating,
  error,
}

/// Provider de usuários
class UsersProvider extends ChangeNotifier {
  final GetCurrentUserProfileUseCase _getCurrentUserProfileUseCase;
  final GetAllUsersUseCase _getAllUsersUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;
  final GetUsersCountUseCase _getUsersCountUseCase;
  final DeleteUserUseCase _deleteUserUseCase;
  final UpdateUserUseCase _updateUserUseCase;

  UsersProvider({
    required GetCurrentUserProfileUseCase getCurrentUserProfileUseCase,
    required GetAllUsersUseCase getAllUsersUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
    required GetUsersCountUseCase getUsersCountUseCase,
    required DeleteUserUseCase deleteUserUseCase,
    required UpdateUserUseCase updateUserUseCase,
  })  : _getCurrentUserProfileUseCase = getCurrentUserProfileUseCase,
        _getAllUsersUseCase = getAllUsersUseCase,
        _changePasswordUseCase = changePasswordUseCase,
        _getUsersCountUseCase = getUsersCountUseCase,
        _deleteUserUseCase = deleteUserUseCase,
        _updateUserUseCase = updateUserUseCase;

  // Estado
  UsersState _state = UsersState.initial;
  UsersState get state => _state;

  // Estado Count
  int _usersCount = 0;
  int get usersCount => _usersCount;

  // Dados
  UserProfileEntity? _currentUser;
  UserProfileEntity? get currentUser => _currentUser;

  List<UserProfileEntity> _users = [];
  List<UserProfileEntity> get users => _users;

  // Erro
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Mensagem de sucesso
  String? _successMessage;
  String? get successMessage => _successMessage;

  /// Obtém perfil do usuário atual
  Future<void> getCurrentUser() async {
    _setState(UsersState.loading);
    _clearError();

    final result = await _getCurrentUserProfileUseCase();
    result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
      },
      (user) {
        _currentUser = user;
        _setState(UsersState.loaded);
      },
    );
  }

  /// Lista todos os usuários (admin)
  Future<void> getAllUsers() async {
    _setState(UsersState.loading);
    _clearError();

    final result = await _getAllUsersUseCase();
    result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
      },
      (users) {
        _users = users;
        _setState(UsersState.loaded);
      },
    );
  }

  /// Atualiza perfil de usuário (admin)
  Future<bool> updateUser(
    String id, {
    String? name,
    TypeRole? role
  }) async {
    _setState(UsersState.updating);
    _clearError();
    _clearSuccess();

    final result = await _updateUserUseCase(
      id,
      name: name,
      role: role,
    );

    final success = result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        return false;
      },
      (_) {
        _successMessage = 'Perfil atualizado com sucesso';
        _setState(UsersState.loaded);
        return true;
      },
    );

    return success;
  }

  /// Altera senha
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _setState(UsersState.updating);
    _clearError();
    _clearSuccess();

    final result = await _changePasswordUseCase(currentPassword, newPassword);

    final success = result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        return false;
      },
      (_) {
        _successMessage = 'Senha alterada com sucesso';
        _setState(UsersState.loaded);
        return true;
      },
    );

    return success;
  }

  /// Obtém contagem total de usuários
  Future<void> getUsersCount() async {
    final result = await _getUsersCountUseCase();
    result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
      },
      (count) {
        _usersCount = count;
        notifyListeners();
      },
    );
  }

  /// Deleta um usuário (admin)
  Future<bool> deleteUser(String userId) async {
    _setState(UsersState.updating);
    _clearError();
    _clearSuccess();

    final result = await _deleteUserUseCase(userId);

    final success = result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        return false;
      },
      (_) {
        _users.removeWhere((user) => user.id == userId);
        _successMessage = 'Usuário deletado com sucesso';
        _setState(UsersState.loaded);
        return true;
      },
    );

    return success;
  }

  /// Limpa erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpa mensagem de sucesso
  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  // Helpers
  void _setState(UsersState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = UsersState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _clearSuccess() {
    _successMessage = null;
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case AuthFailure _:
        return failure.message;
      case ServerFailure _:
        return 'Erro no servidor: ${failure.message}';
      case ConnectionFailure _:
        return 'Sem conexão com a internet';
      case TimeoutFailure _:
        return 'Tempo de espera excedido';
      case ValidationFailure _:
        return 'Dados inválidos: ${failure.message}';
      default:
        return 'Ocorreu um erro inesperado';
    }
  }
}
