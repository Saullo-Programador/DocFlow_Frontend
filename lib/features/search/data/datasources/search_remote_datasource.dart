import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/search_result_model.dart';

/// Interface para fonte de dados remota de busca
abstract class SearchRemoteDataSource {
  /// Busca global (arquivos + pastas)
  Future<List<SearchResultModel>> searchGlobal(String query);

  /// Busca apenas arquivos
  Future<List<SearchResultModel>> searchFiles(String query);

  /// Busca apenas pastas
  Future<List<SearchResultModel>> searchFolders(String query);

  /// Busca em pasta específica
  Future<List<SearchResultModel>> searchInFolder(String query, String folderId);
}

/// Implementação usando Dio
class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final DioClient _dioClient;

  SearchRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<List<SearchResultModel>> searchGlobal(String query) async {
    final response = await _dioClient.get(
      '${ApiConstants.searchBase}/global',
      queryParameters: {'query': query},
    );

    return _parseResults(response.data);
  }

  @override
  Future<List<SearchResultModel>> searchFiles(String query) async {
    final response = await _dioClient.get(
      '${ApiConstants.searchBase}/files',
      queryParameters: {'query': query},
    );

    return _parseResults(response.data);
  }

  @override
  Future<List<SearchResultModel>> searchFolders(String query) async {
    final response = await _dioClient.get(
      '${ApiConstants.searchBase}/folders',
      queryParameters: {'query': query},
    );

    return _parseResults(response.data);
  }

  @override
  Future<List<SearchResultModel>> searchInFolder(
    String query,
    String folderId,
  ) async {
    final response = await _dioClient.get(
      '${ApiConstants.searchBase}/files-in-folder',
      queryParameters: {
        'query': query,
        'folderId': folderId,
      },
    );

    return _parseResults(response.data);
  }

  List<SearchResultModel> _parseResults(dynamic data) {
    if (data == null) return [];

    final list = data as List<dynamic>?;
    return list
            ?.map((json) => SearchResultModel.fromJson(json as Map<String, dynamic>))
            .toList() ??
        [];
  }
}
