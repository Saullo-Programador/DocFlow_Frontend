import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/folder_entity.dart';
import '../repositories/folders_repository.dart';

/// Caso de uso: Listar pastas raiz
class GetRootFoldersUseCase {
  final FoldersRepository _repository;

  GetRootFoldersUseCase(this._repository);

  Future<Either<Failure, List<FolderEntity>>> call() {
    return _repository.getRootFolders();
  }
}

/// Caso de uso: Obter conteúdo da pasta
class GetFolderContentUseCase {
  final FoldersRepository _repository;

  GetFolderContentUseCase(this._repository);

  Future<Either<Failure, FolderContent>> call(String path) {
    return _repository.getFolderContent(path);
  }
}

/// Caso de uso: Criar pasta
class CreateFolderUseCase {
  final FoldersRepository _repository;

  CreateFolderUseCase(this._repository);

  Future<Either<Failure, FolderEntity>> call(
    String name, {
    String? parentId,
  }) {
    return _repository.createFolder(name, parentId: parentId);
  }
}

/// Caso de uso: Pastas filhas
class GetChildFoldersUseCase {
  final FoldersRepository _repository;

  GetChildFoldersUseCase(this._repository);

  Future<Either<Failure, List<FolderEntity>>> call(String parentId) {
    return _repository.getChildFolders(parentId);
  }
}

/// Caso de uso: Renomear pasta
class RenameFolderUseCase {
  final FoldersRepository _repository;

  RenameFolderUseCase(this._repository);

  Future<Either<Failure, FolderEntity>> call(String id, String newName) {
    return _repository.renameFolder(id, newName);
  }
}

/// Caso de uso: Deletar pasta
class DeleteFolderUseCase {
  final FoldersRepository _repository;

  DeleteFolderUseCase(this._repository);

  Future<Either<Failure, void>> call(String path) {
    return _repository.deleteFolder(path);
  }
}

/// Caso de uso: Contagem de pastas
class GetFoldersCountUseCase {
  final FoldersRepository _repository;

  GetFoldersCountUseCase(this._repository);

  Future<Either<Failure, int>> call() {
    return _repository.getFoldersCount();
  }
}
