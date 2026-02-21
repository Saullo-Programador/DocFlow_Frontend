import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;
import 'package:http/http.dart' as http;
import 'package:manege_doc/models/Item_model.dart';
import 'package:manege_doc/models/file.dart';

class Api {
  String baseUrl = "http://localhost:8080";

  Future<void> getHome() async {
    try {
      http.Response response = await http.get(Uri.parse("$baseUrl/documents"));

      if (response.statusCode == 200) {
        print(response.body);
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> createFolder(String name) async {
    try {
      final uri = Uri.parse(
        "$baseUrl/documents/folders",
      ).replace(queryParameters: {"name": name});

      final response = await http.post(uri);
      if (response.statusCode == 201) {
        print("Folder created successfully");
      } else {
        print("Error creating folder: ${response.statusCode}");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List<String>> getFolders() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/documents/folders"));

      if (response.statusCode == 200) {
        return List<String>.from(jsonDecode(response.body));
      } else {
        print("Error ao buscar pastas: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<ItemModel>> getFolderContent(String path) async {
    try {
      final uri = Uri.parse(
        "$baseUrl/documents",
      ).replace(queryParameters: {"path": path});

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<ItemModel> items = [];

        // pastas
        for (final folder in data['folders']) {
          items.add(
            ItemModel.folder(folder, path.isEmpty ? folder : "$path/$folder"),
          );
        }

        // arquivos
        for (final file in data['files']) {
          items.add(ItemModel.file(FileModel.fromJson(file)));
        }

        return items;
      }

      return [];
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<void> uploadFile(String filePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/documents/upload"),
      );
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var response = await request.send();

      if (response.statusCode == 200) {
        print("File uploaded successfully");
      } else {
        print("Error uploading file: ${response.statusCode}");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> download(String fileName) async {
    try {
      final uri = Uri.parse("$baseUrl/documents/download/$fileName");
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        print("Error: ${response.statusCode}");
        return;
      }

      if (kIsWeb) {
        final blob = html.Blob([response.bodyBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);

        html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();

        html.Url.revokeObjectUrl(url);
      } else {
        final file = File("/storage/emulated/0/Download/$fileName");
        await file.writeAsBytes(response.bodyBytes);
        print("Arquivo salvo!");
      }
    } catch (e) {
      print(e);
    }
  }
}
