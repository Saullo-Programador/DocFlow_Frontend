import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/history_item_entity.dart';
import '../repositories/history_repository.dart';

/// Caso de uso: Obter histórico
class GetHistoryUseCase {
  final HistoryRepository _repository;

  GetHistoryUseCase(this._repository);

  Future<Either<Failure, List<HistoryItemEntity>>> call({
    int limit = 50,
    int offset = 0,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _repository.getHistory(
      limit: limit,
      offset: offset,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

/// Caso de uso: Histórico de arquivo
class GetFileHistoryUseCase {
  final HistoryRepository _repository;

  GetFileHistoryUseCase(this._repository);

  Future<Either<Failure, List<HistoryItemEntity>>> call(String fileId) {
    return _repository.getFileHistory(fileId);
  }
}

/// Caso de uso: Histórico de pasta
class GetFolderHistoryUseCase {
  final HistoryRepository _repository;

  GetFolderHistoryUseCase(this._repository);

  Future<Either<Failure, List<HistoryItemEntity>>> call(String folderId) {
    return _repository.getFolderHistory(folderId);
  }
}
