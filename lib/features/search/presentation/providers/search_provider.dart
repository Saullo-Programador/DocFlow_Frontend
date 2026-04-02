import 'package:flutter/material.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/search_result_entity.dart';
import '../../domain/usecases/search_usecases.dart';

/// Estados do provider de busca
enum SearchState {
  initial,
  searching,
  loaded,
  empty,
  error,
}

/// Provider de busca
class SearchProvider extends ChangeNotifier {
  final SearchGlobalUseCase _searchGlobalUseCase;
  final SearchFilesUseCase _searchFilesUseCase;
  final SearchFoldersUseCase _searchFoldersUseCase;
  final SearchInFolderUseCase _searchInFolderUseCase;

  SearchProvider({
    required SearchGlobalUseCase searchGlobalUseCase,
    required SearchFilesUseCase searchFilesUseCase,
    required SearchFoldersUseCase searchFoldersUseCase,
    required SearchInFolderUseCase searchInFolderUseCase,
  })  : _searchGlobalUseCase = searchGlobalUseCase,
        _searchFilesUseCase = searchFilesUseCase,
        _searchFoldersUseCase = searchFoldersUseCase,
        _searchInFolderUseCase = searchInFolderUseCase;

  // Estado
  SearchState _state = SearchState.initial;
  SearchState get state => _state;

  // Dados
  List<SearchResultEntity> _results = [];
  List<SearchResultEntity> get results => _results;

  // Query atual
  String _currentQuery = '';
  String get currentQuery => _currentQuery;

  // Tipo de filtro
  SearchFilter _filter = SearchFilter.all;
  SearchFilter get filter => _filter;

  // Erro
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Busca global
  Future<void> search(String query) async {
    if (query.isEmpty) {
      clearResults();
      return;
    }

    _currentQuery = query;
    _setState(SearchState.searching);
    _clearError();

    late final dynamic result;

    switch (_filter) {
      case SearchFilter.files:
        result = await _searchFilesUseCase(query);
        break;
      case SearchFilter.folders:
        result = await _searchFoldersUseCase(query);
        break;
      case SearchFilter.all:
        result = await _searchGlobalUseCase(query);
        break;
    }

    result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
      },
      (items) {
        _results = items;
        if (items.isEmpty) {
          _setState(SearchState.empty);
        } else {
          _setState(SearchState.loaded);
        }
      },
    );
  }

  /// Busca em pasta específica
  Future<void> searchInFolder(String query, String folderId) async {
    if (query.isEmpty) {
      clearResults();
      return;
    }

    _currentQuery = query;
    _setState(SearchState.searching);
    _clearError();

    final result = await _searchInFolderUseCase(query, folderId);
    result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
      },
      (items) {
        _results = items;
        if (items.isEmpty) {
          _setState(SearchState.empty);
        } else {
          _setState(SearchState.loaded);
        }
      },
    );
  }

  /// Define filtro
  void setFilter(SearchFilter filter) {
    _filter = filter;
    notifyListeners();
    // Refaz busca se houver query
    if (_currentQuery.isNotEmpty) {
      search(_currentQuery);
    }
  }

  /// Limpa resultados
  void clearResults() {
    _results = [];
    _currentQuery = '';
    _setState(SearchState.initial);
  }

  /// Limpa erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Helpers
  void _setState(SearchState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = SearchState.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure) {
      case ServerFailure _:
        return 'Erro no servidor: ${failure.message}';
      case ConnectionFailure _:
        return 'Sem conexão com a internet';
      case TimeoutFailure _:
        return 'Tempo de espera excedido';
      default:
        return 'Ocorreu um erro inesperado';
    }
  }
}

/// Tipos de filtro de busca
enum SearchFilter {
  all,
  files,
  folders,
}
