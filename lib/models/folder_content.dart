

import 'package:manege_doc/models/file.dart';

class FolderContent {
  final List<String> folders;
  final List<FileModel> files;

  FolderContent({
    required this.folders,
    required this.files,
  });

  factory FolderContent.fromJson(Map<String, dynamic> json) {
    return FolderContent(
      folders: List<String>.from(json['folders'] ?? []),
      files: (json['files'] as List<dynamic>? ?? [])
          .map((e) => FileModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'folders': folders,
      'files': files.map((e) => e.toJson()).toList(),
    };
  }
}
