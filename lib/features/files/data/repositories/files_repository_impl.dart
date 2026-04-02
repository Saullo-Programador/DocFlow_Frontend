import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/file_entity.dart';
import '../../domain/repositories/files_repository.dart';
import '../datasources/files_remote_datasource.dart';

/// Implementação do repositório de arquivos
class FilesRepositoryImpl implements FilesRepository {
  final FilesRemoteDataSource _remoteDataSource;

  FilesRepositoryImpl({required FilesRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<FileEntity>>> getFiles(String path) async {
    try {
      final files = await _remoteDataSource.getFiles(path);
      return Right(files.map((model) => model.toEntity()).toList());
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
  Future<Either<Failure, FileEntity>> uploadFile(
    Uint8List bytes,
    String fileName, {
    String path = '',
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final file = await _remoteDataSource.uploadFile(
        bytes,
        fileName,
        path: path,
        onProgress: onProgress,
      );
      return Right(file.toEntity());
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } on ApiException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Uint8List>> downloadFile(String filePath) async {
    try {
      final bytes = await _remoteDataSource.downloadFile(filePath);
      return Right(bytes);
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } on NotFoundException {
      return const Left(NotFoundFailure('Arquivo não encontrado'));
    } on ApiException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteFile(String path) async {
    try {
      await _remoteDataSource.deleteFile(path);
      return const Right(null);
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } on NotFoundException {
      return const Left(NotFoundFailure('Arquivo não encontrado'));
    } on ApiException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, FileEntity>> renameFile(
    String path,
    String newName,
  ) async {
    try {
      final file = await _remoteDataSource.renameFile(path, newName);
      return Right(file.toEntity());
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } on ConflictException {
      return const Left(ConflictFailure('Já existe arquivo com esse nome'));
    } on ApiException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, FileEntity>> moveFile(
    String path,
    String destination,
  ) async {
    try {
      final file = await _remoteDataSource.moveFile(path, destination);
      return Right(file.toEntity());
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } on NotFoundException {
      return const Left(NotFoundFailure('Arquivo ou destino não encontrado'));
    } on ApiException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<FileEntity>>> getLatestUploads(
      {int limit = 10}) async {
    try {
      final files = await _remoteDataSource.getLatestUploads(limit: limit);
      return Right(files.map((model) => model.toEntity()).toList());
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } on ApiException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, int>> getFilesCount() async {
    try {
      final count = await _remoteDataSource.getFilesCount();
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

// Failures específicas
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class ConflictFailure extends Failure {
  const ConflictFailure(super.message);
}
