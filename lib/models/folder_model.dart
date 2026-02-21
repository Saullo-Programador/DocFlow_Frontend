class FolderModel {
  String name;
  List<FolderModel> children;

  FolderModel({
    required this.name,
    List<FolderModel>? children,
  }) : children = children ?? [];
}
