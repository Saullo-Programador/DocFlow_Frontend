import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/file_model.dart';

/// Interface para fonte de dados remota de arquivos
abstract class FilesRemoteDataSource {
  /// Lista arquivos em um caminho
  Future<List<FileModel>> getFiles(String path);

  /// Upload de arquivo (bytes)
  Future<FileModel> uploadFile(
    Uint8List bytes,
    String fileName, {
    String path = '',
    void Function(int sent, int total)? onProgress,
  });

  /// Download de arquivo
  Future<Uint8List> downloadFile(String filePath);

  /// Deleta arquivo
  Future<void> deleteFile(String path);

  /// Renomeia arquivo
  Future<FileModel> renameFile(String path, String newName);

  /// Move arquivo
  Future<FileModel> moveFile(String path, String destination);

  /// Obtém uploads recentes
  Future<List<FileModel>> getLatestUploads({int limit = 10});

  /// Obtém contagem total de arquivos
  Future<int> getFilesCount();
}

/// Implementação usando Dio
class FilesRemoteDataSourceImpl implements FilesRemoteDataSource {
  final DioClient _dioClient;

  FilesRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<List<FileModel>> getFiles(String path) async {
    final response = await _dioClient.get(
      ApiConstants.documentsBase,
      queryParameters: {'path': path},
    );

    final data = response.data as Map<String, dynamic>;
    final files = data['files'] as List<dynamic>?;

    return files
            ?.map((json) => FileModel.fromJson(json as Map<String, dynamic>))
            .toList() ??
        [];
  }

  @override
  Future<FileModel> uploadFile(
    Uint8List bytes,
    String fileName, {
    String path = '',
    void Function(int sent, int total)? onProgress,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });

    final response = await _dioClient.upload(
      '${ApiConstants.documentsBase}/upload',
      formData: formData,
      queryParameters: {'path': path},
      onSendProgress: onProgress,
    );

    return FileModel.fromJson(response.data);
  }

  @override
  Future<Uint8List> downloadFile(String filePath) async {
    final response = await _dioClient.download(
      '${ApiConstants.documentsBase}/download',
      queryParameters: {'path': filePath},
    );

    return Uint8List.fromList(response.data ?? []);
  }

  @override
  Future<void> deleteFile(String path) async {
    await _dioClient.delete(
      '${ApiConstants.documentsBase}/delete/file',
      queryParameters: {'path': path},
    );
  }

  @override
  Future<FileModel> renameFile(String path, String newName) async {
    final response = await _dioClient.put(
      '${ApiConstants.documentsBase}/rename',
      queryParameters: {
        'path': path,
        'newName': newName,
      },
    );

    return FileModel.fromJson(response.data);
  }

  @override
  Future<FileModel> moveFile(String path, String destination) async {
    final response = await _dioClient.put(
      '${ApiConstants.documentsBase}/move',
      queryParameters: {
        'path': path,
        'destination': destination,
      },
    );

    return FileModel.fromJson(response.data);
  }

  @override
  Future<List<FileModel>> getLatestUploads({int limit = 10}) async {
    final response = await _dioClient.get(
      '${ApiConstants.documentsBase}/latest-uploads',
      queryParameters: {'limit': limit},
    );

    final data = response.data as List<dynamic>?;
    return data
            ?.map((json) => FileModel.fromJson(json as Map<String, dynamic>))
            .toList() ??
        [];
  }

  @override
  Future<int> getFilesCount() async {
    final response = await _dioClient.get(
      '${ApiConstants.documentsBase}/count',
    );

    return int.parse(response.data.toString());
  }
}
