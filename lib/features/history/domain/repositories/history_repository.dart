import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/history_item_entity.dart';

/// Interface do repositório de histórico
abstract class HistoryRepository {
  /// Obtém histórico de atividades
  Future<Either<Failure, List<HistoryItemEntity>>> getHistory({
    int limit,
    int offset,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Obtém histórico de um arquivo específico
  Future<Either<Failure, List<HistoryItemEntity>>> getFileHistory(String fileId);

  /// Obtém histórico de uma pasta específica
  Future<Either<Failure, List<HistoryItemEntity>>> getFolderHistory(
      String folderId);
}
