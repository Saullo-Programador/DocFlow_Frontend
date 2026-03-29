import 'dart:async';

import 'package:flutter/material.dart';
import 'package:manege_doc/api/api.dart';
import 'package:manege_doc/constants.dart';
import 'package:manege_doc/models/Item_model.dart';
import 'package:manege_doc/responsive/responsive.dart';
import 'package:manege_doc/screen/folderList/components/item_file.dart';
import 'package:manege_doc/screen/folderList/components/item_folder.dart';
import 'package:manege_doc/screen/folderList/components/new_folder_dialog.dart';
import 'package:manege_doc/screen/folderList/components/top_bar_folder.dart';
import 'package:manege_doc/screen/folderList/components/upload_document_dialog.dart';

class FolderScreen extends StatefulWidget {
  const FolderScreen({super.key});

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  final TextEditingController searchController = TextEditingController();
  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Timer? _debounce;
  bool isSearching = false;
  String currentPath = "";
  List<ItemModel> items = [];

  List<String> navigationStack = [""];

  @override
  void initState() {
    super.initState();
    _loadFolder("");
  }

  Future<void> _loadFolder(String path) async {
    final folderContent = await Api().getFolderContent(path);

    if (!mounted) return;

    setState(() {
      currentPath = path;
      items = folderContent;
    });

    print("Itens recebidos: ${folderContent.length}");
  }

  void _openFolder(String newPath) {
    navigationStack.add(newPath);
    _loadFolder(newPath);
  }

  void _goBack() {
    if (navigationStack.length > 1) {
      navigationStack.removeLast();
      _loadFolder(navigationStack.last);
    }
  }

  void _download(String path) {
    Api().download(path);
  }

  Future<void> _searchGlobal(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        isSearching = false;
      });

      _loadFolder(currentPath);
      return;
    }

    try {
      final results = await Api().searchGlobal(query.trim());

      if (!mounted) return;

      setState(() {
        isSearching = true;
        items = results.cast<ItemModel>();
      });
    } catch (e) {
      debugPrint("Erro na busca: $e");
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchGlobal(query);
    });
  }

  Future<void> _deleteFile(String path) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Excluir arquivo"),
        content: const Text("Tem certeza que deseja excluir este arquivo?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await Api().deleteFile(path);

      if (!mounted) return;

      await _loadFolder(currentPath);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Arquivo deletado com sucesso")),
      );
    } catch (e) {
      debugPrint("Erro ao deletar: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Erro ao deletar arquivo")));
    }
  }

  Future<void> _deleteFolder(String path) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Excluir pasta"),
        content: const Text("Tem certeza que deseja excluir esta pasta?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await Api().deleteFolder(path);

      if (!mounted) return;

      await _loadFolder(currentPath);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pasta deletada com sucesso")),
      );
    } catch (e) {
      debugPrint("Erro ao deletar: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Erro ao deletar Pasta")));
    }
  }

  void _createNewFolder() async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => const NewFolderDialog(),
    );

    if (result != null && result.trim().isNotEmpty) {
      await Api().createFolder(
        currentPath.isEmpty ? result.trim() : "$currentPath/${result.trim()}",
      );

      await _loadFolder(currentPath);
    }
  }

  void _openUploadDialog() {
    showDialog(
      context: context,
      builder: (_) => UploadDocumentDialog(currentPath: currentPath),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = Responsive.isMobile(context);
    final isDesktop = Responsive.isDesktop(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : defaultPadding),
        child: Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 1200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.05),
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pastas e Arquivos",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Gerencie seus documentos e organização",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Conteúdo
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        // TopBar
                        TopBarFolder(
                          searchController: searchController,
                          onUploadDocument: _openUploadDialog,
                          onNewFolder: _createNewFolder,
                          onSearch: _onSearchChanged,
                        ),
                        const SizedBox(height: 20),

                        // Breadcrumb
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                    navigationStack.length > 1
                                        ? primaryColor.withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.1),
                                  ),
                                ),
                                onPressed: navigationStack.length > 1 ? _goBack : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Wrap(
                                  children: List.generate(navigationStack.length, (index) {
                                    final folder = navigationStack[index].isEmpty
                                        ? "Home"
                                        : navigationStack[index].split("/").last;

                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            navigationStack = navigationStack.sublist(
                                              0,
                                              index + 1,
                                            );
                                            _loadFolder(navigationStack.last);
                                          },
                                          child: Text(
                                            folder,
                                            style: TextStyle(
                                              color: primaryColor,
                                              fontWeight: FontWeight.w500,
                                              fontSize: isMobile ? 14 : 16,
                                            ),
                                          ),
                                        ),
                                        if (index != navigationStack.length - 1)
                                          const Text(" > "),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Divider(thickness: 1),
                        const SizedBox(height: 16),

                        if (isSearching)
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                "Resultados da busca",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),

                        // Lista de itens
                        SizedBox(
                          height: 500,
                          child: items.isEmpty
                              ? const Center(
                                  child: Text(
                                    "Nenhum item encontrado",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : LayoutBuilder(
                                  builder: (context, constraints) {
                                    if (isDesktop && constraints.maxWidth > 800) {
                                      return GridView.builder(
                                        gridDelegate:
                                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 300,
                                          childAspectRatio: 3,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                        ),
                                        itemCount: items.length,
                                        itemBuilder: (context, index) {
                                          final item = items[index];
                                          return _buildItem(item);
                                        },
                                      );
                                    }
                                    return ListView.builder(
                                      itemCount: items.length,
                                      itemBuilder: (context, index) {
                                        final item = items[index];
                                        return _buildItem(item);
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(ItemModel item) {
    if (item.type == ItemType.folder) {
      return ItemFolder(
        folderName: item.name,
        onTap: () => _openFolder(item.path),
        onDeleteFolder: () => _deleteFolder(item.path),
        onEditFolder: () {},
      );
    }

    return ItemFile(
      fileName: item.name,
      onTap: () {},
      onDeleteFile: () => _deleteFile(item.path),
      onDownloadFile: () => _download(item.path),
      onMoverFile: () {},
    );
  }
}