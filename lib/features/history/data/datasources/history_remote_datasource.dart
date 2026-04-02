import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/history_item_model.dart';

/// Interface para fonte de dados remota de histórico
abstract class HistoryRemoteDataSource {
  /// Obtém histórico de atividades
  Future<List<HistoryItemModel>> getHistory({
    int limit = 50,
    int offset = 0,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Obtém histórico de um arquivo específico
  Future<List<HistoryItemModel>> getFileHistory(String fileId);

  /// Obtém histórico de uma pasta específica
  Future<List<HistoryItemModel>> getFolderHistory(String folderId);
}

/// Implementação usando Dio
class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final DioClient _dioClient;

  HistoryRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<List<HistoryItemModel>> getHistory({
    int limit = 50,
    int offset = 0,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };

    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }

    final response = await _dioClient.get(
      ApiConstants.historyBase,
      queryParameters: queryParams,
    );

    final data = response.data as List<dynamic>?;
    return data
            ?.map((json) =>
                HistoryItemModel.fromJson(json as Map<String, dynamic>))
            .toList() ??
        [];
  }

  @override
  Future<List<HistoryItemModel>> getFileHistory(String fileId) async {
    final response = await _dioClient.get(
      '${ApiConstants.historyBase}/file/$fileId',
    );

    final data = response.data as List<dynamic>?;
    return data
            ?.map((json) =>
                HistoryItemModel.fromJson(json as Map<String, dynamic>))
            .toList() ??
        [];
  }

  @override
  Future<List<HistoryItemModel>> getFolderHistory(String folderId) async {
    final response = await _dioClient.get(
      '${ApiConstants.historyBase}/folder/$folderId',
    );

    final data = response.data as List<dynamic>?;
    return data
            ?.map((json) =>
                HistoryItemModel.fromJson(json as Map<String, dynamic>))
            .toList() ??
        [];
  }
}
