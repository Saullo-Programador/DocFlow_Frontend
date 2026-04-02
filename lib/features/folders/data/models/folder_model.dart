import '../../domain/entities/folder_entity.dart';

/// Modelo de pasta da API
class FolderModel {
  final String id;
  final String name;
  final String path;
  final String? parentId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? fileCount;
  final int? subfolderCount;

  FolderModel({
    required this.id,
    required this.name,
    required this.path,
    this.parentId,
    this.createdAt,
    this.updatedAt,
    this.fileCount,
    this.subfolderCount,
  });

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    return FolderModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      path: json['path']?.toString() ?? json['id']?.toString() ?? '',
      parentId: json['parentId']?.toString() ?? json['parent']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      fileCount: json['fileCount'] as int? ?? json['files']?.length,
      subfolderCount: json['subfolderCount'] as int? ?? json['folders']?.length,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      if (parentId != null) 'parentId': parentId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (fileCount != null) 'fileCount': fileCount,
      if (subfolderCount != null) 'subfolderCount': subfolderCount,
    };
  }

  /// Converte para entidade de domínio
  FolderEntity toEntity() {
    return FolderEntity(
      id: id,
      name: name,
      path: path,
      parentId: parentId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      itemCount: (fileCount ?? 0) + (subfolderCount ?? 0),
    );
  }

  /// Retorna o nome do path (último segmento)
  String get displayName => name.isEmpty ? path.split('/').last : name;

  /// Nível de profundidade na árvore
  int get depth => path.split('/').where((s) => s.isNotEmpty).length;

  /// Path dos pais
  String? get parentPath {
    final parts = path.split('/');
    if (parts.length <= 1) return null;
    parts.removeLast();
    return parts.join('/');
  }
}
