import 'package:flutter/material.dart';
import '../../../../core/errors/failures.dart';
import '../../../files/domain/entities/file_entity.dart';
import '../../domain/entities/folder_entity.dart';
import '../../domain/usecases/folders_usecases.dart';

/// Estados do provider de pastas
enum FoldersState {
  initial,
  loading,
  loaded,
  creating,
  renaming,
  deleting,
  error,
}

/// Provider de pastas
class FoldersProvider extends ChangeNotifier {
  final GetRootFoldersUseCase _getRootFoldersUseCase;
  final GetFolderContentUseCase _getFolderContentUseCase;
  final CreateFolderUseCase _createFolderUseCase;
  final RenameFolderUseCase _renameFolderUseCase;
  final DeleteFolderUseCase _deleteFolderUseCase;

  FoldersProvider({
    required GetRootFoldersUseCase getRootFoldersUseCase,
    required GetFolderContentUseCase getFolderContentUseCase,
    required CreateFolderUseCase createFolderUseCase,
    required RenameFolderUseCase renameFolderUseCase,
    required DeleteFolderUseCase deleteFolderUseCase,
  })  : _getRootFoldersUseCase = getRootFoldersUseCase,
        _getFolderContentUseCase = getFolderContentUseCase,
        _createFolderUseCase = createFolderUseCase,
        _renameFolderUseCase = renameFolderUseCase,
        _deleteFolderUseCase = deleteFolderUseCase;

  // Estado
  FoldersState _state = FoldersState.initial;
  FoldersState get state => _state;

  // Dados
  List<FolderEntity> _folders = [];
  List<FolderEntity> get folders => _folders;

  List<FileEntity> _files = [];
  List<FileEntity> get files => _files;

  FolderEntity? _currentFolder;
  FolderEntity? get currentFolder => _currentFolder;

  String _currentPath = '';
  String get currentPath => _currentPath;

  // Breadcrumb de navegação
  List<FolderEntity> _breadcrumb = [];
  List<FolderEntity> get breadcrumb => _breadcrumb;

  // Erro
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Lista pastas raiz
  Future<void> getRootFolders() async {
    _setState(FoldersState.loading);
    _clearError();

    final result = await _getRootFoldersUseCase();
    result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
      },
      (folders) {
        _folders = folders;
        _setState(FoldersState.loaded);
      },
    );
  }

  /// Obtém conteúdo de uma pasta
  Future<void> getFolderContent(String path) async {
    _setState(FoldersState.loading);
    _clearError();

    _currentPath = path;

    final result = await _getFolderContentUseCase(path);
    result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
      },
      (content) {
        _folders = content.folders;
        _files = (content.files as List<FileEntity>);
        _setState(FoldersState.loaded);
      },
    );
  }

  /// Cria nova pasta
  Future<bool> createFolder(
    String name, {
    String? parentPath,
    String? parentId,
  }) async {
    _setState(FoldersState.creating);
    _clearError();

    final result = await _createFolderUseCase(
      name,
      parentPath: parentPath,
      parentId: parentId,
    );

    final success = result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        return false;
      },
      (folder) {
        _folders.add(folder);
        _setState(FoldersState.loaded);
        return true;
      },
    );

    return success;
  }

  /// Navega para uma pasta
  Future<void> navigateToFolder(FolderEntity folder) async {
    _currentFolder = folder;
    _breadcrumb.add(folder);
    await getFolderContent(folder.fullPath);
  }

  /// Volta para a pasta anterior
  Future<void> navigateUp() async {
    if (_breadcrumb.isNotEmpty) {
      _breadcrumb.removeLast();
      if (_breadcrumb.isEmpty) {
        _currentFolder = null;
        await getRootFolders();
      } else {
        _currentFolder = _breadcrumb.last;
        await getFolderContent(_currentFolder!.fullPath);
      }
    }
  }

  /// Navega para raiz
  Future<void> navigateToRoot() async {
    _currentFolder = null;
    _breadcrumb = [];
    _currentPath = '';
    await getRootFolders();
  }

  /// Renomeia pasta
  Future<bool> renameFolder(String id, String newName) async {
    _setState(FoldersState.renaming);
    _clearError();

    final result = await _renameFolderUseCase(id, newName);

    final success = result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        return false;
      },
      (folder) {
        final index = _folders.indexWhere((f) => f.id == id);
        if (index != -1) {
          _folders[index] = folder;
        }
        _setState(FoldersState.loaded);
        return true;
      },
    );

    return success;
  }

  /// Deleta pasta
  Future<bool> deleteFolder(String path) async {
    _setState(FoldersState.deleting);
    _clearError();

    final result = await _deleteFolderUseCase(path);

    final success = result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        return false;
      },
      (_) {
        _folders.removeWhere((f) => f.fullPath == path);
        _setState(FoldersState.loaded);
        return true;
      },
    );

    return success;
  }

  /// Limpa erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Helpers
  void _setState(FoldersState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = FoldersState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Erro no servidor: ${failure.message}';
      case ConnectionFailure:
        return 'Sem conexão com a internet';
      case TimeoutFailure:
        return 'Tempo de espera excedido';
      case ValidationFailure:
        return 'Dados inválidos: ${failure.message}';
      default:
        return 'Ocorreu um erro inesperado';
    }
  }
}
