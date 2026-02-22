import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:manege_doc/api/api.dart';
import 'package:manege_doc/constants.dart';
import 'package:manege_doc/models/Item_model.dart';
import 'package:manege_doc/responsive/responsive.dart';

class UploadDocumentDialog extends StatefulWidget {
  final String currentPath;
  const UploadDocumentDialog({super.key, required this.currentPath});

  @override
  State<UploadDocumentDialog> createState() => _UploadDocumentDialogState();
}

class _UploadDocumentDialogState extends State<UploadDocumentDialog> {
  final TextEditingController fileNameController = TextEditingController();
  final TextEditingController pathFolderController = TextEditingController();

  List<String> folderSuggestions = [];
  bool isLoadingFolders = false;
  Timer? _debounce;
  File? selectedFile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    pathFolderController.text = widget.currentPath;

    // carrega pastas iniciais
    _loadFolderSuggestions(widget.currentPath);

    // escuta digitando
    pathFolderController.addListener(_onPathChanged);
  }

  @override
  void dispose() {
    pathFolderController.removeListener(_onPathChanged);
    _debounce?.cancel();
    fileNameController.dispose();
    pathFolderController.dispose();
    super.dispose();
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: false);

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
        fileNameController.text = result.files.single.name;
      });
    }
  }

  Future<void> uploadFile() async {
    if (selectedFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Selecione um arquivo")));
      return;
    }
    try {
      setState(() => isLoading = true);

      final manualPath = pathFolderController.text.trim();

      final finalPath = manualPath.isEmpty ? widget.currentPath : manualPath;

      await Api().uploadFile(selectedFile!.path, path: finalPath);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro no upload: $e")));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _loadFolderSuggestions(String path) async {
    try {
      setState(() => isLoadingFolders = true);

      final items = await Api().getFolderContent(path);

      final folders = items
          .where((e) => e.type == ItemType.folder)
          .map((e) => e.name)
          .toList();

      if (!mounted) return;

      setState(() {
        folderSuggestions = folders;
      });
    } catch (e) {
      debugPrint("Erro ao carregar pastas: $e");
    } finally {
      if (mounted) {
        setState(() => isLoadingFolders = false);
      }
    }
  }

  void _onPathChanged() {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 350), () {
      final text = pathFolderController.text.trim();

      String basePath;

      if (text.isEmpty) {
        basePath = widget.currentPath;
      } else if (text.contains("/")) {
        basePath = text.substring(0, text.lastIndexOf("/"));
      } else {
        basePath = "";
      }

      _loadFolderSuggestions(basePath);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = Responsive.isDesktop(context)
        ? 900.0
        : Responsive.isTablet(context)
        ? 700.0
        : MediaQuery.of(context).size.width * 0.95;

    final dialogHeight = Responsive.isDesktop(context)
        ? 500.0
        : Responsive.isTablet(context)
        ? 450.0
        : MediaQuery.of(context).size.height * 0.7;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: isLoading ? null : uploadFile,
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: const Text(
                    "Enviar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
        ),
      ],
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Upload de Documento",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),
              GestureDetector(
                onTap: pickFile,
                child: Container(
                  height: dialogHeight * 0.5,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryColor),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: primaryColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        selectedFile == null
                            ? "Clique para selecionar o arquivo"
                            : "Arquivo selecionado:\n${fileNameController.text}",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 📝 Nome do Arquivo
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Nome do Arquivo",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 6),
              TextField(
                controller: fileNameController,
                decoration: const InputDecoration(
                  hintText: "Ex: contrato_janeiro.pdf",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// 📁 Caminho da Pasta
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Salvar em",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: pathFolderController,
                decoration: const InputDecoration(
                  // ignore: unnecessary_string_escapes
                  hintText: "Opcional — ex: contratos/2025",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
              if (folderSuggestions.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: folderSuggestions.length,
                    itemBuilder: (context, index) {
                      final folder = folderSuggestions[index];

                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.folder, color: primaryColor),
                        title: Text(folder),
                        onTap: () {
                          final current = pathFolderController.text;

                          final newPath = current.contains("/")
                              ? "${current.substring(0, current.lastIndexOf("/"))}/$folder"
                              : folder;

                          pathFolderController.text = newPath;
                          pathFolderController.selection =
                              TextSelection.fromPosition(
                                TextPosition(offset: newPath.length),
                              );
                        },
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
