import 'package:equatable/equatable.dart';

/// Entidade de arquivo (domínio)
class FileEntity extends Equatable {
  final String id;
  final String name;
  final String path;
  final int size;
  final String mimeType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FileEntity({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.mimeType,
    this.createdAt,
    this.updatedAt,
  });

  /// Nome completo com caminho
  String get fullPath => path.isEmpty ? name : '$path/$name';

  /// Extensão do arquivo
  String get extension {
    final dotIndex = name.lastIndexOf('.');
    return dotIndex > 0 ? name.substring(dotIndex + 1).toLowerCase() : '';
  }

  /// Formata o tamanho do arquivo
  String get formattedSize {
    if (size == 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    var s = size.toDouble();

    while (s >= 1024 && i < suffixes.length - 1) {
      s /= 1024;
      i++;
    }

    return '${s.toStringAsFixed(2)} ${suffixes[i]}';
  }

  @override
  List<Object?> get props => [id, name, path, size, mimeType, createdAt, updatedAt];

  /// Cria cópia com novos valores
  FileEntity copyWith({
    String? id,
    String? name,
    String? path,
    int? size,
    String? mimeType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      size: size ?? this.size,
      mimeType: mimeType ?? this.mimeType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
