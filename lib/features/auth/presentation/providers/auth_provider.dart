import 'package:flutter/material.dart';
import 'package:manege_doc/core/constants/type_role.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_auth_status_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/password_recovery_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

/// Estados possíveis da autenticação
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Provider de autenticação
class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final IsLoggedInUseCase _isLoggedInUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final VerifyCodeUseCase _verifyCodeUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;

  AuthProvider({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required IsLoggedInUseCase isLoggedInUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required VerifyCodeUseCase verifyCodeUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _isLoggedInUseCase = isLoggedInUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _forgotPasswordUseCase = forgotPasswordUseCase,
        _verifyCodeUseCase = verifyCodeUseCase,
        _resetPasswordUseCase = resetPasswordUseCase;

  // Estado
  AuthState _state = AuthState.initial;
  AuthState get state => _state;

  UserEntity? _user;
  UserEntity? get user => _user;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Verifica se usuário está logado (chamar no início do app)
  Future<void> checkAuthStatus() async {
    _setLoading(true);

    final result = await _isLoggedInUseCase();
    result.fold(
      (failure) => _setState(AuthState.unauthenticated),
      (isLoggedIn) async {
        if (isLoggedIn) {
          await _loadCurrentUser();
        } else {
          _setState(AuthState.unauthenticated);
        }
      },
    );

    _setLoading(false);
  }

  /// Carrega usuário atual
  Future<void> _loadCurrentUser() async {
    final result = await _getCurrentUserUseCase();
    result.fold(
      (failure) => _setState(AuthState.unauthenticated),
      (user) {
        _user = user;
        _setState(user != null ? AuthState.authenticated : AuthState.unauthenticated);
      },
    );
  }

  /// Realiza login
  Future<bool> login(String name, String password) async {
    _setLoading(true);
    _clearError();

    final result = await _loginUseCase(name, password);

    final success = result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        return false;
      },
      (auth) {
        _user = auth.user;
        _setState(AuthState.authenticated);
        return true;
      },
    );

    _setLoading(false);
    return success;
  }

  /// Registra novo usuário
  Future<bool> register(
    String email,
    TypeRole role,
    String password, {
    String? name,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _registerUseCase(email, role, password, name: name);

    final success = result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        return false;
      },
      (auth) {
        _user = auth.user;
        _setState(AuthState.authenticated);
        return true;
      },
    );

    _setLoading(false);
    return success;
  }

  /// Faz logout
  Future<void> logout() async {
    _setLoading(true);

    await _logoutUseCase();
    _user = null;
    _setState(AuthState.unauthenticated);

    _setLoading(false);
  }

  /// Solicita recuperação de senha
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _clearError();

    final result = await _forgotPasswordUseCase(email);

    final success = result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        return false;
      },
      (_) => true,
    );

    _setLoading(false);
    return success;
  }

  /// Verifica código de recuperação
  Future<bool> verifyCode(String email, String code) async {
    _setLoading(true);
    _clearError();

    final result = await _verifyCodeUseCase(email, code);

    final success = result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        return false;
      },
      (_) => true,
    );

    _setLoading(false);
    return success;
  }

  /// Reseta senha
  Future<bool> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    _setLoading(true);
    _clearError();

    final result = await _resetPasswordUseCase(email, code, newPassword);

    final success = result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        return false;
      },
      (_) => true,
    );

    _setLoading(false);
    return success;
  }

  /// Limpa mensagem de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Helpers privados
  void _setState(AuthState state) {
    _state = state;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = AuthState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
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
