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
  Future<FolderModel> createFolder(String path, {String? parentId});

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

    final folders = (data['folders'] as List<dynamic>?)
            ?.map((f) => FolderModel(
                  id: f.toString(),
                  name: f.toString().split('/').last,
                  path: f.toString(),
                ))
            .toList() ??
        [];

    return FolderContentModel(
      folders: folders,
      files: data['files'] as List<dynamic>? ?? [],
      currentPath: path,
    );
  }

  @override
  Future<FolderModel> createFolder(String path, {String? parentId}) async {
    await _dioClient.post(
      '${ApiConstants.documentsBase}/folders',
      queryParameters: {'path': path},
    );

    // Criar modelo de resposta (API não retorna o objeto completo)
    final folderName = path.split('/').last;
    return FolderModel(
      id: path,
      name: folderName,
      path: path,
      parentId: parentId,
    );
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

    return response.data['count'] as int? ?? 0;
  }
}
