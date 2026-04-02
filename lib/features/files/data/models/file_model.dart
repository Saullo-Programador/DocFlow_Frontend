import '../../domain/entities/file_entity.dart';

/// Modelo de arquivo da API
class FileModel {
  final String id;
  final String name;
  final String? path;
  final int? size;
  final String? mimeType;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? ownerId;

  FileModel({
    required this.id,
    required this.name,
    this.path,
    this.size,
    this.mimeType,
    this.createdAt,
    this.updatedAt,
    this.ownerId,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      path: json['path']?.toString(),
      size: json['size'] as int?,
      mimeType: json['mimeType']?.toString() ?? json['type']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      ownerId: json['ownerId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (path != null) 'path': path,
      if (size != null) 'size': size,
      if (mimeType != null) 'mimeType': mimeType,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (ownerId != null) 'ownerId': ownerId,
    };
  }

  /// Converte para entidade de domínio
  FileEntity toEntity() {
    return FileEntity(
      id: id,
      name: name,
      path: path ?? '',
      size: size ?? 0,
      mimeType: mimeType ?? 'application/octet-stream',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Formata o tamanho do arquivo (KB, MB, etc.)
  String get formattedSize {
    if (size == null || size == 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    var s = size!.toDouble();

    while (s >= 1024 && i < suffixes.length - 1) {
      s /= 1024;
      i++;
    }

    return '${s.toStringAsFixed(2)} ${suffixes[i]}';
  }

  /// Extensão do arquivo
  String get extension {
    final dotIndex = name.lastIndexOf('.');
    return dotIndex > 0 ? name.substring(dotIndex + 1).toLowerCase() : '';
  }

  /// Icon baseado no tipo
  String get iconType {
    if (mimeType?.startsWith('image/') ?? false) return 'image';
    if (mimeType?.contains('pdf') ?? false) return 'pdf';
    if ((mimeType?.contains('word') ?? false) || name.endsWith('.doc')) return 'document';
    if ((mimeType?.contains('excel') ?? false) || name.endsWith('.xls')) return 'spreadsheet';
    if ((mimeType?.contains('powerpoint') ?? false) || name.endsWith('.ppt')) return 'presentation';
    if (mimeType?.startsWith('video/') ?? false) return 'video';
    if (mimeType?.startsWith('audio/') ?? false) return 'audio';
    return 'file';
  }
}
