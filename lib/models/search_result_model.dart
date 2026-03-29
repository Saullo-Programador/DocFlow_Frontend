import 'package:manege_doc/models/Item_model.dart';

class SearchResult {
  final int id;
  final String name;
  final String type;
  final String path;

  SearchResult({
    required this.id,
    required this.name,
    required this.type,
    required this.path,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      path: json['path'],
    );
  }

  ItemModel toItemModel() {
    return ItemModel(
      name: name,
      path: path,
      type: type == "folder" ? ItemType.folder : ItemType.file,
    );
  }
}