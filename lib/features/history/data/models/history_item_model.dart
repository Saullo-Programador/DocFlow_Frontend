import '../../domain/entities/history_item_entity.dart';

/// Modelo de item de histórico da API
class HistoryItemModel {
  final String id;
  final HistoryActionType action;
  final String? targetId;
  final String? targetName;
  final HistoryTargetType targetType;
  final String? userId;
  final String? userName;
  final DateTime timestamp;
  final Map<String, dynamic>? details;
  final String? ipAddress;

  HistoryItemModel({
    required this.id,
    required this.action,
    this.targetId,
    this.targetName,
    required this.targetType,
    this.userId,
    this.userName,
    required this.timestamp,
    this.details,
    this.ipAddress,
  });

  factory HistoryItemModel.fromJson(Map<String, dynamic> json) {
    return HistoryItemModel(
      id: json['id']?.toString() ?? '',
      action: _parseAction(json['action']?.toString() ?? 'unknown'),
      targetId: json['targetId']?.toString() ?? json['fileId']?.toString(),
      targetName: json['targetName']?.toString() ?? json['fileName']?.toString(),
      targetType: _parseTargetType(json['targetType']?.toString()),
      userId: json['userId']?.toString(),
      userName: json['userName']?.toString(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'].toString())
          : DateTime.now(),
      details: json['details'] as Map<String, dynamic>?,
      ipAddress: json['ipAddress']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action.name,
      if (targetId != null) 'targetId': targetId,
      if (targetName != null) 'targetName': targetName,
      'targetType': targetType.name,
      if (userId != null) 'userId': userId,
      if (userName != null) 'userName': userName,
      'timestamp': timestamp.toIso8601String(),
      if (details != null) 'details': details,
      if (ipAddress != null) 'ipAddress': ipAddress,
    };
  }

  /// Converte para entidade de domínio
  HistoryItemEntity toEntity() {
    return HistoryItemEntity(
      id: id,
      action: action,
      targetId: targetId ?? '',
      targetName: targetName ?? 'Desconhecido',
      targetType: targetType,
      userId: userId,
      userName: userName,
      timestamp: timestamp,
      details: details,
    );
  }

  /// Descrição legível da ação
  String get actionDescription {
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
        return 'Entrou';
      case HistoryActionType.logout:
        return 'Saiu';
      case HistoryActionType.unknown:
        return 'Ação desconhecida';
    }
  }

  /// Descrição completa do item
  String get fullDescription {
    final actionStr = actionDescription.toLowerCase();
    final typeStr = targetType == HistoryTargetType.folder ? 'pasta' : 'arquivo';
    return '$actionStr ${targetName ?? typeStr}';
  }
}

/// Tipos de ação no histórico
enum HistoryActionType {
  create,
  update,
  delete,
  move,
  rename,
  download,
  share,
  login,
  logout,
  unknown,
}

/// Tipos de alvo no histórico
enum HistoryTargetType { file, folder, user, system }

HistoryActionType _parseAction(String action) {
  switch (action.toLowerCase()) {
    case 'create':
    case 'created':
    case 'upload':
    case 'uploaded':
      return HistoryActionType.create;
    case 'update':
    case 'updated':
      return HistoryActionType.update;
    case 'delete':
    case 'deleted':
      return HistoryActionType.delete;
    case 'move':
    case 'moved':
      return HistoryActionType.move;
    case 'rename':
    case 'renamed':
      return HistoryActionType.rename;
    case 'download':
    case 'downloaded':
      return HistoryActionType.download;
    case 'share':
    case 'shared':
      return HistoryActionType.share;
    case 'login':
      return HistoryActionType.login;
    case 'logout':
      return HistoryActionType.logout;
    default:
      return HistoryActionType.unknown;
  }
}

HistoryTargetType _parseTargetType(String? type) {
  switch (type?.toLowerCase()) {
    case 'folder':
    case 'directory':
      return HistoryTargetType.folder;
    case 'user':
      return HistoryTargetType.user;
    case 'system':
      return HistoryTargetType.system;
    case 'file':
    default:
      return HistoryTargetType.file;
  }
}
