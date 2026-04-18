import 'package:dartz/dartz.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';

/// Implementação do repositório de autenticação
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, AuthEntity>> login(String name, String password) async {
    try {
      final request = LoginRequestModel(name: name, password: password);
      final response = await _remoteDataSource.login(request);

      // Salvar tokens localmente
      await _localDataSource.saveAccessToken(response.accessToken);
      if (response.refreshToken != null) {
        await _localDataSource.saveRefreshToken(response.refreshToken!);
      }
      await _localDataSource.saveUserData(response.user.toJson());

      return Right(AuthEntity(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        user: response.user.toEntity(),
      ));
    } on UnauthorizedException {
      return const Left(AuthFailure('Email ou senha incorretos'));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } on TimeoutException {
      return const Left(TimeoutFailure());
    } on ApiException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> register(
    String email,
    String password, {
    String? name,
  }) async {
    try {
      final request = RegisterRequestModel(
        email: email,
        password: password,
        name: name,
      );
      final response = await _remoteDataSource.register(request);

      // Salvar tokens
      await _localDataSource.saveAccessToken(response.accessToken);
      if (response.refreshToken != null) {
        await _localDataSource.saveRefreshToken(response.refreshToken!);
      }
      await _localDataSource.saveUserData(response.user.toJson());

      return Right(AuthEntity(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        user: response.user.toEntity(),
      ));
    } on ConflictException {
      return const Left(AuthFailure('Email já cadastrado'));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } on ApiException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _localDataSource.clearTokens();
      return const Right(null);
    } catch (e) {
      // Mesmo se falhar no servidor, limpar localmente
      await _localDataSource.clearTokens();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final isLoggedIn = await _localDataSource.isLoggedIn();
      return Right(isLoggedIn);
    } catch (e) {
      return const Left(CacheFailure('Erro ao verificar sessão'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final userData = await _localDataSource.getUserData();
      if (userData == null) return const Right(null);

      // Reconstruir entidade
      return Right(UserEntity(
        id: userData['id']?.toString() ?? '',
        email: userData['email']?.toString() ?? '',
        name: userData['name']?.toString(),
        role: userData['role']?.toString(),
        avatarUrl: userData['avatarUrl']?.toString(),
      ));
    } catch (e) {
      return const Left(CacheFailure('Erro ao obter usuário'));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await _remoteDataSource.forgotPassword(email);
      return const Right(null);
    } on NotFoundException {
      return const Left(AuthFailure('Email não encontrado'));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } on ApiException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> verifyCode(String email, String code) async {
    try {
      await _remoteDataSource.verifyCode(email, code);
      return const Right(null);
    } on BadRequestException {
      return const Left(AuthFailure('Código inválido'));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } on ApiException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      await _remoteDataSource.resetPassword(email, code, newPassword);
      return const Right(null);
    } on BadRequestException {
      return const Left(AuthFailure('Não foi possível redefinir a senha'));
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } on ApiException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }
}
