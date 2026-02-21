import 'package:manege_doc/models/file.dart';

enum ItemType { folder, file }

class ItemModel {
  final String name;
  final String path;
  final ItemType type;
  final int? size;
  final String? downloadUrl;

  ItemModel({
    required this.name,
    required this.path,
    required this.type,
    this.size,
    this.downloadUrl,
  });

  factory ItemModel.folder(String name, String path) {
    return ItemModel(
      name: name,
      path: path,
      type: ItemType.folder,
      size: null,
    );
  }

  factory ItemModel.file(FileModel file) {
    return ItemModel(
      name: file.name,
      path: file.path,
      type: ItemType.file,
      size: file.size,
      downloadUrl: file.downloadUrl,
    );
  }
}
