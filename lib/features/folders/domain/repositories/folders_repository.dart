import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/folder_entity.dart';

/// Modelo de conteúdo de pasta (pastas + arquivos)
class FolderContent {
  final List<FolderEntity> folders;
  final List<dynamic> files;
  final String currentPath;

  FolderContent({
    required this.folders,
    required this.files,
    required this.currentPath,
  });
}

/// Interface do repositório de pastas
abstract class FoldersRepository {
  /// Lista pastas raiz
  Future<Either<Failure, List<FolderEntity>>> getRootFolders();

  /// Obtém conteúdo de uma pasta
  Future<Either<Failure, FolderContent>> getFolderContent(String path);

  /// Cria nova pasta
  Future<Either<Failure, FolderEntity>> createFolder(
    String name, {
    String? parentPath,
    String? parentId,
  });

  /// Obtém pastas filhas
  Future<Either<Failure, List<FolderEntity>>> getChildFolders(String parentId);

  /// Renomeia pasta
  Future<Either<Failure, FolderEntity>> renameFolder(String id, String newName);

  /// Deleta pasta
  Future<Either<Failure, void>> deleteFolder(String path);

  /// Obtém contagem total de pastas
  Future<Either<Failure, int>> getFoldersCount();
}
