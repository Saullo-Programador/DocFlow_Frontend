import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/file_entity.dart';
import '../../domain/usecases/files_usecases.dart';

/// Estados do provider de arquivos
enum FilesState {
  initial,
  loading,
  loaded,
  uploading,
  downloading,
  error,
}

/// Provider de arquivos
class FilesProvider extends ChangeNotifier {
  final GetFilesUseCase _getFilesUseCase;
  final UploadFileUseCase _uploadFileUseCase;
  final DownloadFileUseCase _downloadFileUseCase;
  final DeleteFileUseCase _deleteFileUseCase;
  final RenameFileUseCase _renameFileUseCase;
  final MoveFileUseCase _moveFileUseCase;
  final GetLatestUploadsUseCase _getLatestUploadsUseCase;

  FilesProvider({
    required GetFilesUseCase getFilesUseCase,
    required UploadFileUseCase uploadFileUseCase,
    required DownloadFileUseCase downloadFileUseCase,
    required DeleteFileUseCase deleteFileUseCase,
    required RenameFileUseCase renameFileUseCase,
    required MoveFileUseCase moveFileUseCase,
    required GetLatestUploadsUseCase getLatestUploadsUseCase,
  })  : _getFilesUseCase = getFilesUseCase,
        _uploadFileUseCase = uploadFileUseCase,
        _downloadFileUseCase = downloadFileUseCase,
        _deleteFileUseCase = deleteFileUseCase,
        _renameFileUseCase = renameFileUseCase,
        _moveFileUseCase = moveFileUseCase,
        _getLatestUploadsUseCase = getLatestUploadsUseCase;

  // Estado
  FilesState _state = FilesState.initial;
  FilesState get state => _state;

  // Dados
  List<FileEntity> _files = [];
  List<FileEntity> get files => _files;

  List<FileEntity> _latestUploads = [];
  List<FileEntity> get latestUploads => _latestUploads;

  FileEntity? _selectedFile;
  FileEntity? get selectedFile => _selectedFile;

  Uint8List? _downloadedFile;
  Uint8List? get downloadedFile => _downloadedFile;

  // Progresso de upload
  double _uploadProgress = 0;
  double get uploadProgress => _uploadProgress;

  // Erro
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Lista arquivos em um caminho
  Future<void> getFiles(String path) async {
    _setState(FilesState.loading);
    _clearError();

    final result = await _getFilesUseCase(path);
    result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
      },
      (files) {
        _files = files;
        _setState(FilesState.loaded);
      },
    );
  }

  /// Upload de arquivo
  Future<bool> uploadFile(
    Uint8List bytes,
    String fileName, {
    String path = '',
  }) async {
    _setState(FilesState.uploading);
    _uploadProgress = 0;
    _clearError();

    final result = await _uploadFileUseCase(
      bytes,
      fileName,
      path: path,
      onProgress: (sent, total) {
        _uploadProgress = total > 0 ? sent / total : 0;
        notifyListeners();
      },
    );

    final success = result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        return false;
      },
      (file) {
        _files.insert(0, file);
        _setState(FilesState.loaded);
        return true;
      },
    );

    _uploadProgress = 0;
    return success;
  }

  /// Download de arquivo
  Future<bool> downloadFile(String filePath) async {
    _setState(FilesState.downloading);
    _clearError();

    final result = await _downloadFileUseCase(filePath);

    final success = result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        return false;
      },
      (bytes) {
        _downloadedFile = bytes;
        _setState(FilesState.loaded);
        return true;
      },
    );

    return success;
  }

  /// Deleta arquivo
  Future<bool> deleteFile(String path) async {
    _clearError();

    final result = await _deleteFileUseCase(path);

    return result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        return false;
      },
      (_) {
        _files.removeWhere((f) => f.fullPath == path);
        notifyListeners();
        return true;
      },
    );
  }

  /// Renomeia arquivo
  Future<bool> renameFile(String path, String newName) async {
    _clearError();

    final result = await _renameFileUseCase(path, newName);

    return result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        return false;
      },
      (file) {
        final index = _files.indexWhere((f) => f.fullPath == path);
        if (index != -1) {
          _files[index] = file;
          notifyListeners();
        }
        return true;
      },
    );
  }

  /// Move arquivo
  Future<bool> moveFile(String path, String destination) async {
    _clearError();

    final result = await _moveFileUseCase(path, destination);

    return result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        return false;
      },
      (file) {
        final index = _files.indexWhere((f) => f.fullPath == path);
        if (index != -1) {
          _files[index] = file;
          notifyListeners();
        }
        return true;
      },
    );
  }

  /// Obtém uploads recentes
  Future<void> getLatestUploads({int limit = 10}) async {
    _clearError();

    final result = await _getLatestUploadsUseCase(limit: limit);
    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (files) {
        _latestUploads = files;
        notifyListeners();
      },
    );
  }

  /// Seleciona arquivo
  void selectFile(FileEntity file) {
    _selectedFile = file;
    notifyListeners();
  }

  /// Limpa seleção
  void clearSelection() {
    _selectedFile = null;
    _downloadedFile = null;
    notifyListeners();
  }

  /// Limpa erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Helpers
  void _setState(FilesState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = FilesState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return 'Erro no servidor: ${failure.message}';
      case ConnectionFailure _:
        return 'Sem conexão com a internet';
      case TimeoutFailure _:
        return 'Tempo de espera excedido';
      case ValidationFailure _:
        return 'Dados inválidos: ${failure.message}';
      default:
        return 'Ocorreu um erro inesperado';
    }
  }
}
