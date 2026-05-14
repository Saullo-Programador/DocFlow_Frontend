import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/folder_model.dart';

/// Interface para fonte de dados remota de pastas
abstract class FoldersRemoteDataSource {
  /// Lista todas as pastas raiz
  Future<List<String>> getRootFolders();

  /// Lista conteúdo de uma pasta (pastas + arquivos)
  Future<FolderContentModel> getFolderContent(String path);

  /// Cria nova pasta
  Future<FolderModel> createFolder(String name, {String? parentId});

  /// Obtém pastas filhas de uma pasta
  Future<List<FolderModel>> getChildFolders(String parentId);

  /// Renomeia pasta
  Future<FolderModel> renameFolder(String id, String newName);

  /// Deleta pasta
  Future<void> deleteFolder(String path);

  /// Obtém contagem total de pastas
  Future<int> getFoldersCount();
}

/// Modelo de conteúdo de pasta
class FolderContentModel {
  final List<FolderModel> folders;
  final List<dynamic> files;
  final String currentPath;

  FolderContentModel({
    required this.folders,
    required this.files,
    required this.currentPath,
  });
}

/// Implementação usando Dio
class FoldersRemoteDataSourceImpl implements FoldersRemoteDataSource {
  final DioClient _dioClient;

  FoldersRemoteDataSourceImpl({required DioClient dioClient})
    : _dioClient = dioClient;

  @override
  Future<List<String>> getRootFolders() async {
    final response = await _dioClient.get(
      '${ApiConstants.documentsBase}/folders',
    );

    return (response.data as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
  }

  @override
  Future<FolderContentModel> getFolderContent(String path) async {
    final response = await _dioClient.get(
      ApiConstants.documentsBase,
      queryParameters: {'path': path},
    );

    final data = response.data as Map<String, dynamic>;

    final folders =
        (data['folders'] as List<dynamic>?)
            ?.map((f) => FolderModel.fromJson(f as Map<String, dynamic>))
            .toList() ??
        [];

    return FolderContentModel(
      folders: folders,
      files: data['files'] as List<dynamic>? ?? [],
      currentPath: path,
    );
  }

  @override
  Future<FolderModel> createFolder(String name, {String? parentId}) async {
    print("CRIANDO PASTA:");
    print("name: $name");
    print("parentId: $parentId");

    final response = await _dioClient.post(
      '${ApiConstants.documentsBase}/folders',
      data: {
        'name': name,
        if (parentId != null) 'parentId': int.parse(parentId),
      },
    );

    print("STATUS: ${response.statusCode}");
    print("RESPONSE: ${response.data}");

    return FolderModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<FolderModel>> getChildFolders(String parentId) async {
    final response = await _dioClient.get(
      '${ApiConstants.documentsBase}/children',
      queryParameters: {'parentId': parentId},
    );

    return (response.data as List<dynamic>?)
            ?.map((json) => FolderModel.fromJson(json as Map<String, dynamic>))
            .toList() ??
        [];
  }

  @override
  Future<FolderModel> renameFolder(String id, String newName) async {
    final response = await _dioClient.put(
      '${ApiConstants.documentsBase}/$id',
      queryParameters: {'name': newName},
    );

    return FolderModel.fromJson(response.data);
  }

  @override
  Future<void> deleteFolder(String path) async {
    await _dioClient.delete(
      '${ApiConstants.documentsBase}/delete/folder',
      queryParameters: {'path': path},
    );
  }

  @override
  Future<int> getFoldersCount() async {
    final response = await _dioClient.get(
      '${ApiConstants.documentsBase}/folders/count',
    );

    return int.parse(response.data.toString());
  }
}
