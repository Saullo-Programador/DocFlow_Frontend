import 'package:equatable/equatable.dart';
import '../../data/models/history_item_model.dart';

export '../../data/models/history_item_model.dart'
    show HistoryActionType, HistoryTargetType;

/// Entidade de item de histórico
class HistoryItemEntity extends Equatable {
  final String id;
  final HistoryActionType action;
  final String targetId;
  final String targetName;
  final HistoryTargetType targetType;
  final String? userId;
  final String? userName;
  final DateTime timestamp;
  final Map<String, dynamic>? details;

  const HistoryItemEntity({
    required this.id,
    required this.action,
    required this.targetId,
    required this.targetName,
    required this.targetType,
    this.userId,
    this.userName,
    required this.timestamp,
    this.details,
  });

  /// É ação de arquivo?
  bool get isFileAction => targetType == HistoryTargetType.file;

  /// É ação de pasta?
  bool get isFolderAction => targetType == HistoryTargetType.folder;

  /// Descrição legível
  String get description {
    final actionStr = _actionString;
    final typeStr = isFolderAction ? 'pasta' : 'arquivo';
    return '$actionStr $typeStr "$targetName"';
  }

  String get _actionString {
    switch (action) {
      case HistoryActionType.create:
        return 'Criou';
      case HistoryActionType.update:
        return 'Atualizou';
      case HistoryActionType.delete:
        return 'Deletou';
      case HistoryActionType.move:
        return 'Moveu';
      case HistoryActionType.rename:
        return 'Renomeou';
      case HistoryActionType.download:
        return 'Baixou';
      case HistoryActionType.share:
        return 'Compartilhou';
      case HistoryActionType.login:
        return 'Entrou no sistema';
      case HistoryActionType.logout:
        return 'Saiu do sistema';
      case HistoryActionType.unknown:
        return 'Realizou ação em';
    }
  }

  @override
  List<Object?> get props => [
        id,
        action,
        targetId,
        targetName,
        targetType,
        userId,
        userName,
        timestamp,
      ];
}
