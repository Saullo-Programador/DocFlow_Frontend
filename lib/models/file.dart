
class FileModel {
  final String name;
  final String path;
  final String downloadUrl;
  final int size;

  FileModel({
    required this.name,
    required this.path,
    required this.downloadUrl,
    required this.size,
  });

  factory FileModel.fromJson(Map<String, dynamic> json){
    return FileModel(
      name: json['name'],
      path: json['path'],
      downloadUrl: json['downloadUrl'],
      size: json['size'] ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'downloadUrl': downloadUrl,
      'size': size,
    };
  }
}