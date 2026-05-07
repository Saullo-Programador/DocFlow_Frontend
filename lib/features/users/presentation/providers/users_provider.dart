import 'package:flutter/material.dart';
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
  final UpdateProfileUseCase _updateProfileUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;
  final GetUsersCountUseCase _getUsersCountUseCase;

  UsersProvider({
    required GetCurrentUserProfileUseCase getCurrentUserProfileUseCase,
    required GetAllUsersUseCase getAllUsersUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
    required GetUsersCountUseCase getUsersCountUseCase,
  })  : _getCurrentUserProfileUseCase = getCurrentUserProfileUseCase,
        _getAllUsersUseCase = getAllUsersUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _changePasswordUseCase = changePasswordUseCase,
        _getUsersCountUseCase = getUsersCountUseCase;
        
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

  /// Atualiza perfil
  Future<bool> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    _setState(UsersState.updating);
    _clearError();
    _clearSuccess();

    final result = await _updateProfileUseCase(
      name: name,
      avatarUrl: avatarUrl,
    );

    final success = result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        return false;
      },
      (user) {
        _currentUser = user;
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
