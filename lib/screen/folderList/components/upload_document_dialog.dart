import 'dart:async';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:manege_doc/core/constants/app_constants.dart';
import 'package:manege_doc/features/files/presentation/providers/files_provider.dart';
import 'package:manege_doc/features/folders/presentation/providers/folders_provider.dart';
import 'package:manege_doc/responsive/responsive.dart';
import 'package:provider/provider.dart';

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
  Uint8List? selectedFileBytes;
  String? selectedFileName;
  String _lastLoadedPath = "";

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
    debugPrint("📂 Abrindo FilePicker...");

    final result = await FilePicker.platform.pickFiles(
      withData: true,
    );

    if (result == null) {
      debugPrint("❌ Usuário cancelou a seleção");
      return;
    }

    final file = result.files.single;

    debugPrint("✅ Arquivo selecionado:");
    debugPrint("   • Nome: ${file.name}");
    debugPrint("   • Bytes null? ${file.bytes == null}");
    debugPrint("   • Tamanho: ${file.size} bytes");

    if (file.bytes != null) {
      setState(() {
        selectedFileBytes = file.bytes!;
        selectedFileName = file.name;
        fileNameController.text = file.name;
      });

      debugPrint("🚀 Estado atualizado com sucesso");
    } else {
      debugPrint("❌ ERRO: bytes vieram null");
    }
  }

  Future<void> uploadFile() async {
    if (selectedFileBytes == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Selecione um arquivo")));
      return;
    }

    final filesProvider = context.read<FilesProvider>();

    final manualPath = pathFolderController.text.trim();
    final finalPath = manualPath.isEmpty ? widget.currentPath : manualPath;

    debugPrint("📤 Upload path enviado: '$finalPath'");

    final success = await filesProvider.uploadFile(
      selectedFileBytes!,
      selectedFileName!,
      path: finalPath,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Erro no upload: ${filesProvider.errorMessage ?? 'Erro desconhecido'}",
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadFolderSuggestions(String path) async {
    if (path == _lastLoadedPath) return;
    if (isLoadingFolders) return;
    _lastLoadedPath = path;

    final foldersProvider = context.read<FoldersProvider>();

    try {
      setState(() => isLoadingFolders = true);

      await foldersProvider.getFolderContent(path);

      if (!mounted) return;

      setState(() {
        folderSuggestions = foldersProvider.folders.map((f) => f.name).toList();
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
        basePath = widget.currentPath;
      }

      _loadFolderSuggestions(basePath);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filesProvider = context.watch<FilesProvider>();
    final isUploading = filesProvider.state == FilesState.uploading;

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
          onPressed: isUploading ? null : () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              "Cancelar",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: isUploading ? null : uploadFile,
          child: isUploading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
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
                onTap: isUploading ? null : pickFile,
                child: Container(
                  height: dialogHeight * 0.5,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppConstants.primaryColor),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: AppConstants.primaryColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        selectedFileBytes == null
                            ? "Clique para selecionar o arquivo"
                            : "Arquivo selecionado:\n$selectedFileName",
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selectedFileBytes == null
                              ? Colors.black
                              : AppConstants.primaryColor,
                          fontWeight: selectedFileBytes == null
                              ? FontWeight.normal
                              : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              /// Nome do Arquivo
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Nome do Arquivo",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: fileNameController,
                enabled: !isUploading,
                decoration: const InputDecoration(
                  hintText: "Ex: contrato_janeiro.pdf",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// Caminho da Pasta
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Salvar em",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: pathFolderController,
                enabled: !isUploading,
                decoration: const InputDecoration(
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
                        leading: const Icon(Icons.folder,
                            color: AppConstants.primaryColor),
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
