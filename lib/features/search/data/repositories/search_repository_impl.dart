import 'package:dartz/dartz.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/search_result_entity.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_datasource.dart';

/// Implementação do repositório de busca
class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource _remoteDataSource;

  SearchRepositoryImpl({required SearchRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<SearchResultEntity>>> searchGlobal(
      String query) async {
    return _executeSearch(() => _remoteDataSource.searchGlobal(query));
  }

  @override
  Future<Either<Failure, List<SearchResultEntity>>> searchFiles(String query) async {
    return _executeSearch(() => _remoteDataSource.searchFiles(query));
  }

  @override
  Future<Either<Failure, List<SearchResultEntity>>> searchFolders(
      String query) async {
    return _executeSearch(() => _remoteDataSource.searchFolders(query));
  }

  @override
  Future<Either<Failure, List<SearchResultEntity>>> searchInFolder(
    String query,
    String folderId,
  ) async {
    return _executeSearch(() => _remoteDataSource.searchInFolder(query, folderId));
  }

  Future<Either<Failure, List<SearchResultEntity>>> _executeSearch(
    Future<List<dynamic>> Function() searchFn,
  ) async {
    try {
      final results = await searchFn();
      final entities = results.map((r) => r.toEntity() as SearchResultEntity).toList();
      return Right(entities);
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } on TimeoutException {
      return const Left(TimeoutFailure());
    } on ApiException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }
}
