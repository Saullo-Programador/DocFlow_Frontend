import 'package:dartz/dartz.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/history_item_entity.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_remote_datasource.dart';

/// Implementação do repositório de histórico
class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource _remoteDataSource;

  HistoryRepositoryImpl({required HistoryRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<HistoryItemEntity>>> getHistory({
    int limit = 50,
    int offset = 0,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final models = await _remoteDataSource.getHistory(
        limit: limit,
        offset: offset,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(models.map((m) => m.toEntity()).toList());
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

  @override
  Future<Either<Failure, List<HistoryItemEntity>>> getFileHistory(
      String fileId) async {
    try {
      final models = await _remoteDataSource.getFileHistory(fileId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } on TimeoutException {
      return const Left(TimeoutFailure());
    } on NotFoundException {
      return const Left(ServerFailure('Arquivo não encontrado', statusCode: 404));
    } on ApiException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<HistoryItemEntity>>> getFolderHistory(
      String folderId) async {
    try {
      final models = await _remoteDataSource.getFolderHistory(folderId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ConnectionException {
      return const Left(ConnectionFailure());
    } on TimeoutException {
      return const Left(TimeoutFailure());
    } on NotFoundException {
      return const Left(ServerFailure('Pasta não encontrada', statusCode: 404));
    } on ApiException catch (e) {
      return Left(ServerFailure.fromException(e));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }
}
