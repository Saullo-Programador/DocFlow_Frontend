import '../../domain/entities/search_result_entity.dart';

/// Modelo de resultado de busca da API
class SearchResultModel {
  final String id;
  final String name;
  final SearchResultType type;
  final String? path;
  final String? mimeType;
  final int? size;
  final DateTime? modifiedAt;
  final double? relevanceScore;

  SearchResultModel({
    required this.id,
    required this.name,
    required this.type,
    this.path,
    this.mimeType,
    this.size,
    this.modifiedAt,
    this.relevanceScore,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    // Detectar tipo pelo campo ou extensão
    final typeStr = json['type']?.toString().toLowerCase();
    final name = json['name']?.toString() ?? '';

    SearchResultType type;
    if (typeStr == 'folder' || json['isFolder'] == true) {
      type = SearchResultType.folder;
    } else {
      type = SearchResultType.file;
    }

    return SearchResultModel(
      id: json['id']?.toString() ?? '',
      name: name,
      type: type,
      path: json['path']?.toString(),
      mimeType: json['mimeType']?.toString(),
      size: json['size'] as int?,
      modifiedAt: json['modifiedAt'] != null
          ? DateTime.tryParse(json['modifiedAt'].toString())
          : null,
      relevanceScore: json['relevance'] != null
          ? (json['relevance'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      if (path != null) 'path': path,
      if (mimeType != null) 'mimeType': mimeType,
      if (size != null) 'size': size,
      if (modifiedAt != null) 'modifiedAt': modifiedAt!.toIso8601String(),
      if (relevanceScore != null) 'relevance': relevanceScore,
    };
  }

  /// Converte para entidade de domínio
  SearchResultEntity toEntity() {
    return SearchResultEntity(
      id: id,
      name: name,
      type: type,
      path: path ?? '',
      mimeType: mimeType,
      size: size,
      modifiedAt: modifiedAt,
    );
  }

  /// Extensão do arquivo (se aplicável)
  String? get fileExtension {
    if (type == SearchResultType.folder) return null;
    final dotIndex = name.lastIndexOf('.');
    return dotIndex > 0 ? name.substring(dotIndex + 1).toLowerCase() : null;
  }

  /// Ícone baseado no tipo
  String get iconType {
    if (type == SearchResultType.folder) return 'folder';
    if (mimeType?.startsWith('image/') ?? false) return 'image';
    if (mimeType?.contains('pdf') ?? false) return 'pdf';
    if (mimeType?.contains('word') ?? false) return 'document';
    if (mimeType?.contains('excel') ?? false) return 'spreadsheet';
    return 'file';
  }
}
