import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/search_result_entity.dart';
import '../repositories/search_repository.dart';

/// Caso de uso: Busca global
class SearchGlobalUseCase {
  final SearchRepository _repository;

  SearchGlobalUseCase(this._repository);

  Future<Either<Failure, List<SearchResultEntity>>> call(String query) {
    return _repository.searchGlobal(query);
  }
}

/// Caso de uso: Buscar arquivos
class SearchFilesUseCase {
  final SearchRepository _repository;

  SearchFilesUseCase(this._repository);

  Future<Either<Failure, List<SearchResultEntity>>> call(String query) {
    return _repository.searchFiles(query);
  }
}

/// Caso de uso: Buscar pastas
class SearchFoldersUseCase {
  final SearchRepository _repository;

  SearchFoldersUseCase(this._repository);

  Future<Either<Failure, List<SearchResultEntity>>> call(String query) {
    return _repository.searchFolders(query);
  }
}

/// Caso de uso: Buscar em pasta
class SearchInFolderUseCase {
  final SearchRepository _repository;

  SearchInFolderUseCase(this._repository);

  Future<Either<Failure, List<SearchResultEntity>>> call(
    String query,
    String folderId,
  ) {
    return _repository.searchInFolder(query, folderId);
  }
}
