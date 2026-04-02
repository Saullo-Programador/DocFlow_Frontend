import 'package:flutter/material.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/history_item_entity.dart';
import '../../domain/usecases/history_usecases.dart';

/// Estados do provider de histórico
enum HistoryState {
  initial,
  loading,
  loaded,
  error,
}

/// Provider de histórico
class HistoryProvider extends ChangeNotifier {
  final GetHistoryUseCase _getHistoryUseCase;
  final GetFileHistoryUseCase _getFileHistoryUseCase;
  final GetFolderHistoryUseCase _getFolderHistoryUseCase;

  HistoryProvider({
    required GetHistoryUseCase getHistoryUseCase,
    required GetFileHistoryUseCase getFileHistoryUseCase,
    required GetFolderHistoryUseCase getFolderHistoryUseCase,
  })  : _getHistoryUseCase = getHistoryUseCase,
        _getFileHistoryUseCase = getFileHistoryUseCase,
        _getFolderHistoryUseCase = getFolderHistoryUseCase;

  // Estado
  HistoryState _state = HistoryState.initial;
  HistoryState get state => _state;

  // Dados
  List<HistoryItemEntity> _history = [];
  List<HistoryItemEntity> get history => _history;

  // Paginação
  int _offset = 0;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  // Filtros
  DateTime? _startDate;
  DateTime? get startDate => _startDate;

  DateTime? _endDate;
  DateTime? get endDate => _endDate;

  // Erro
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Obtém histórico (com paginação)
  Future<void> getHistory({
    int limit = 50,
    bool refresh = false,
  }) async {
    if (refresh) {
      _offset = 0;
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return;

    _setState(HistoryState.loading);
    _clearError();

    final result = await _getHistoryUseCase(
      limit: limit,
      offset: _offset,
      startDate: _startDate,
      endDate: _endDate,
    );

    result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
      },
      (items) {
        if (refresh) {
          _history = items;
        } else {
          _history.addAll(items);
        }
        _offset += items.length;
        _hasMore = items.length == limit;
        _setState(HistoryState.loaded);
      },
    );
  }

  /// Carrega mais histórico
  Future<void> loadMore({int limit = 50}) async {
    await getHistory(limit: limit);
  }

  /// Obtém histórico de um arquivo
  Future<void> getFileHistory(String fileId) async {
    _setState(HistoryState.loading);
    _clearError();

    final result = await _getFileHistoryUseCase(fileId);
    result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
      },
      (items) {
        _history = items;
        _setState(HistoryState.loaded);
      },
    );
  }

  /// Obtém histórico de uma pasta
  Future<void> getFolderHistory(String folderId) async {
    _setState(HistoryState.loading);
    _clearError();

    final result = await _getFolderHistoryUseCase(folderId);
    result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
      },
      (items) {
        _history = items;
        _setState(HistoryState.loaded);
      },
    );
  }

  /// Define filtro de data
  void setDateFilter({DateTime? start, DateTime? end}) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  /// Limpa filtros
  void clearFilters() {
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  /// Limpa erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Helpers
  void _setState(HistoryState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = HistoryState.error;
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
      default:
        return 'Ocorreu um erro inesperado';
    }
  }
}
