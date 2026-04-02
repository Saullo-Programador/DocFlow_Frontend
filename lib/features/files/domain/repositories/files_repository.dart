import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/file_entity.dart';

/// Interface do repositório de arquivos
abstract class FilesRepository {
  /// Lista arquivos em um caminho
  Future<Either<Failure, List<FileEntity>>> getFiles(String path);

  /// Upload de arquivo
  Future<Either<Failure, FileEntity>> uploadFile(
    Uint8List bytes,
    String fileName, {
    String path = '',
    void Function(int sent, int total)? onProgress,
  });

  /// Download de arquivo
  Future<Either<Failure, Uint8List>> downloadFile(String filePath);

  /// Deleta arquivo
  Future<Either<Failure, void>> deleteFile(String path);

  /// Renomeia arquivo
  Future<Either<Failure, FileEntity>> renameFile(String path, String newName);

  /// Move arquivo
  Future<Either<Failure, FileEntity>> moveFile(String path, String destination);

  /// Obtém uploads recentes
  Future<Either<Failure, List<FileEntity>>> getLatestUploads({int limit});

  /// Obtém contagem total de arquivos
  Future<Either<Failure, int>> getFilesCount();
}
