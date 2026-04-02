import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/search_result_entity.dart';

/// Interface do repositório de busca
abstract class SearchRepository {
  /// Busca global (arquivos + pastas)
  Future<Either<Failure, List<SearchResultEntity>>> searchGlobal(String query);

  /// Busca apenas arquivos
  Future<Either<Failure, List<SearchResultEntity>>> searchFiles(String query);

  /// Busca apenas pastas
  Future<Either<Failure, List<SearchResultEntity>>> searchFolders(String query);

  /// Busca em pasta específica
  Future<Either<Failure, List<SearchResultEntity>>> searchInFolder(
    String query,
    String folderId,
  );
}
