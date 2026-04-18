import 'package:dartz/dartz.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/errors/failures.dart';
import '../../../files/data/models/file_model.dart';
import '../../domain/entities/folder_entity.dart';
import '../../domain/repositories/folders_repository.dart';
import '../datasources/folders_remote_datasource.dart';

/// Implementação do repositório de pastas
class FoldersRepositoryImpl implements FoldersRepository {
  final FoldersRemoteDataSource _remoteDataSource;

  FoldersRepositoryImpl({required FoldersRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<FolderEntity>>> getRootFolders() async {
    try {
      final folders = await _remoteDataSource.getRootFolders();
      // Converter strings para entidades
      return Right(
        folders
            .map(
              (path) => FolderEntity(
                id: path,
                name: path.split('/').last,
                path: path,
              ),
            )
            .toList(),
      );
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } on ApiException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, FolderContent>> getFolderContent(String path) async {
    try {
      final content = await _remoteDataSource.getFolderContent(path);

      final folders = content.folders.map((m) => m.toEntity()).toList();
      final files = content.files
          .map((f) => FileModel.fromJson(f as Map<String, dynamic>).toEntity())
          .toList();

      return Right(
        FolderContent(
          folders: folders,
          files: files,
          currentPath: content.currentPath,
        ),
      );
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } on NotFoundException {
      return const Left(NotFoundFailure('Pasta não encontrada'));
    } on ApiException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, FolderEntity>> createFolder(
    String name, {
    String? parentId,
  }) async {
    try {
      final folder = await _remoteDataSource.createFolder(
        name,
        parentId: parentId,
      );
      return Right(folder.toEntity());
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } on ConflictException {
      return const Left(ConflictFailure('Pasta já existe'));
    } on ApiException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<FolderEntity>>> getChildFolders(
    String parentId,
  ) async {
    try {
      final folders = await _remoteDataSource.getChildFolders(parentId);
      return Right(folders.map((m) => m.toEntity()).toList());
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } on ApiException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, FolderEntity>> renameFolder(
    String id,
    String newName,
  ) async {
    try {
      final folder = await _remoteDataSource.renameFolder(id, newName);
      return Right(folder.toEntity());
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } on ConflictException {
      return const Left(ConflictFailure('Já existe pasta com esse nome'));
    } on ApiException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteFolder(String path) async {
    try {
      await _remoteDataSource.deleteFolder(path);
      return const Right(null);
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } on BadRequestException {
      return const Left(ValidationFailure('Não foi possível deletar a pasta'));
    } on ApiException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, int>> getFoldersCount() async {
    try {
      final count = await _remoteDataSource.getFoldersCount();
      return Right(count);
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } on ApiException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }
}
