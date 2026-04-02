import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/file_entity.dart';
import '../repositories/files_repository.dart';

/// Caso de uso: Listar arquivos
class GetFilesUseCase {
  final FilesRepository _repository;

  GetFilesUseCase(this._repository);

  Future<Either<Failure, List<FileEntity>>> call(String path) {
    return _repository.getFiles(path);
  }
}

/// Caso de uso: Upload de arquivo
class UploadFileUseCase {
  final FilesRepository _repository;

  UploadFileUseCase(this._repository);

  Future<Either<Failure, FileEntity>> call(
    Uint8List bytes,
    String fileName, {
    String path = '',
    void Function(int sent, int total)? onProgress,
  }) {
    return _repository.uploadFile(bytes, fileName, path: path, onProgress: onProgress);
  }
}

/// Caso de uso: Download de arquivo
class DownloadFileUseCase {
  final FilesRepository _repository;

  DownloadFileUseCase(this._repository);

  Future<Either<Failure, Uint8List>> call(String filePath) {
    return _repository.downloadFile(filePath);
  }
}

/// Caso de uso: Deletar arquivo
class DeleteFileUseCase {
  final FilesRepository _repository;

  DeleteFileUseCase(this._repository);

  Future<Either<Failure, void>> call(String path) {
    return _repository.deleteFile(path);
  }
}

/// Caso de uso: Renomear arquivo
class RenameFileUseCase {
  final FilesRepository _repository;

  RenameFileUseCase(this._repository);

  Future<Either<Failure, FileEntity>> call(String path, String newName) {
    return _repository.renameFile(path, newName);
  }
}

/// Caso de uso: Mover arquivo
class MoveFileUseCase {
  final FilesRepository _repository;

  MoveFileUseCase(this._repository);

  Future<Either<Failure, FileEntity>> call(String path, String destination) {
    return _repository.moveFile(path, destination);
  }
}

/// Caso de uso: Uploads recentes
class GetLatestUploadsUseCase {
  final FilesRepository _repository;

  GetLatestUploadsUseCase(this._repository);

  Future<Either<Failure, List<FileEntity>>> call({int limit = 10}) {
    return _repository.getLatestUploads(limit: limit);
  }
}

/// Caso de uso: Contagem de arquivos
class GetFilesCountUseCase {
  final FilesRepository _repository;

  GetFilesCountUseCase(this._repository);

  Future<Either<Failure, int>> call() {
    return _repository.getFilesCount();
  }
}
