import 'package:dartz/dartz.dart';
import 'package:manege_doc/core/constants/type_role.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/users_repository.dart';
import '../datasources/users_remote_datasource.dart';

/// Implementação do repositório de usuários
class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDataSource _remoteDataSource;

  UsersRepositoryImpl({required UsersRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, UserProfileEntity>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return Right(user.toEntity());
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } on UnauthorizedException {
      return const Left(AuthFailure('Sessão expirada'));
    } on ApiException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<UserProfileEntity>>> getAllUsers() async {
    try {
      final users = await _remoteDataSource.getAllUsers();
      return Right(users.map((m) => m.toEntity()).toList());
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } on ForbiddenException {
      return const Left(ForbiddenFailure('Acesso negado'));
    } on ApiException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final user = await _remoteDataSource.updateProfile(
        name: name,
        avatarUrl: avatarUrl,
      );
      return Right(user.toEntity());
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await _remoteDataSource.changePassword(currentPassword, newPassword);
      return const Right(null);
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } on BadRequestException {
      return const Left(ValidationFailure('Senha atual incorreta'));
    } on ApiException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, int>> getUsersCount() async {
    try {
      final count = await _remoteDataSource.getUsersCount();
      return Right(count);
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } on ApiException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String userId) async {
    try {
      await _remoteDataSource.deleteUser(userId);
      return const Right(null);
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } on ForbiddenException {
      return const Left(ForbiddenFailure('Acesso negado'));
    } on ApiException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateUser(
    String id,{
      String? name, 
      TypeRole? role
    }
  ) async {
    try {
      await _remoteDataSource.updateUser(id, name: name, role: role);
      return const Right(null);
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } on ForbiddenException {
      return const Left(ForbiddenFailure('Acesso negado'));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }
}

// Failure específica
class ForbiddenFailure extends Failure {
  const ForbiddenFailure(super.message);
}
