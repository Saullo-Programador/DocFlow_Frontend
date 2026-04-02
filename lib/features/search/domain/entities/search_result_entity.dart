import 'package:equatable/equatable.dart';

/// Tipo de resultado de busca
enum SearchResultType { file, folder }

/// Entidade de resultado de busca
class SearchResultEntity extends Equatable {
  final String id;
  final String name;
  final SearchResultType type;
  final String path;
  final String? mimeType;
  final int? size;
  final DateTime? modifiedAt;

  const SearchResultEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.path,
    this.mimeType,
    this.size,
    this.modifiedAt,
  });

  /// É pasta?
  bool get isFolder => type == SearchResultType.folder;

  /// É arquivo?
  bool get isFile => type == SearchResultType.file;

  /// Extensão do arquivo
  String? get fileExtension {
    if (isFolder) return null;
    final dotIndex = name.lastIndexOf('.');
    return dotIndex > 0 ? name.substring(dotIndex + 1).toLowerCase() : null;
  }

  @override
  List<Object?> get props => [id, name, type, path, mimeType, size, modifiedAt];
}
