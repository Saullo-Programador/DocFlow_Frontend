import 'package:equatable/equatable.dart';

/// Entidade de pasta (domínio)
class FolderEntity extends Equatable {
  final String id;
  final String name;
  final String path;
  final String? parentId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int itemCount;

  const FolderEntity({
    required this.id,
    required this.name,
    required this.path,
    this.parentId,
    this.createdAt,
    this.updatedAt,
    this.itemCount = 0,
  });

  /// Nome de exibição
  String get displayName => name.isNotEmpty ? name : id.split('/').last;

  /// Caminho completo
  String get fullPath => path.isEmpty ? id : path;

  /// É pasta raiz?
  bool get isRoot => parentId == null || parentId!.isEmpty;

  /// Path do pai
  String? get parentPath {
    final parts = fullPath.split('/');
    if (parts.length <= 1) return null;
    parts.removeLast();
    return parts.isEmpty ? null : parts.join('/');
  }

  @override
  List<Object?> get props => [id, name, path, parentId, createdAt, updatedAt, itemCount];

  /// Cria cópia com novos valores
  FolderEntity copyWith({
    String? id,
    String? name,
    String? path,
    String? parentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? itemCount,
  }) {
    return FolderEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      itemCount: itemCount ?? this.itemCount,
    );
  }
}
