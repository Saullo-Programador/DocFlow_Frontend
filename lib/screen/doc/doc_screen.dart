import 'dart:async';

import 'package:flutter/material.dart';
import 'package:manege_doc/core/constants/app_constants.dart';
import 'package:manege_doc/features/files/domain/entities/file_entity.dart';
import 'package:manege_doc/features/files/presentation/providers/files_provider.dart';
import 'package:manege_doc/features/folders/domain/entities/folder_entity.dart';
import 'package:manege_doc/features/folders/presentation/providers/folders_provider.dart';
import 'package:manege_doc/features/search/presentation/providers/search_provider.dart';
import 'package:manege_doc/responsive/responsive.dart';
import 'package:manege_doc/screen/doc/components/item_file.dart';
import 'package:manege_doc/screen/doc/components/item_folder.dart';
import 'package:manege_doc/screen/doc/components/new_folder_dialog.dart';
import 'package:manege_doc/screen/doc/components/top_bar_folder.dart';
import 'package:manege_doc/screen/doc/components/upload_document_dialog.dart';
import 'package:provider/provider.dart';

/// Modelo de união para itens da lista
sealed class FolderItem {
  final String name;
  final String path;

  const FolderItem({required this.name, required this.path});
}

class FolderItemFolder extends FolderItem {
  final FolderEntity folder;

  const FolderItemFolder({
    required this.folder,
    required super.name,
    required super.path,
  });
}

class FolderItemFile extends FolderItem {
  final FileEntity file;

  const FolderItemFile({
    required this.file,
    required super.name,
    required super.path,
  });
}

class DocScreen extends StatefulWidget {
  const DocScreen({super.key});

  @override
  State<DocScreen> createState() => _DocScreenState();
}

class _DocScreenState extends State<DocScreen> {
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  bool isSearching = false;
  List<FolderItem> items = [];

  List<String> navigationStack = [""];

  @override
  void initState() {
    super.initState();
    _loadFolder("");
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadFolder(String path) async {
    final foldersProvider = context.read<FoldersProvider>();

    await foldersProvider.getFolderContent(path);

    if (!mounted) return;

    // Converte para lista de items unificada
    final newItems = <FolderItem>[];

    // Adiciona pastas
    for (final folder in foldersProvider.folders) {
      newItems.add(
        FolderItemFolder(
          folder: folder,
          name: folder.name,
          path: folder.fullPath,
        ),
      );
    }

    // Adiciona arquivos
    for (final file in foldersProvider.files) {
      newItems.add(
        FolderItemFile(file: file, name: file.name, path: file.fullPath),
      );
    }

    setState(() {
      items = newItems;
      isSearching = false;
    });

    print("Itens recebidos: ${items.length}");
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

  Future<void> _download(String path) async {
    final filesProvider = context.read<FilesProvider>();
    await filesProvider.downloadFile(path);

    if (mounted && filesProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro no download: ${filesProvider.errorMessage}"),
        ),
      );
    }
  }

  Future<void> _searchGlobal(String query) async {
    final searchProvider = context.read<SearchProvider>();

    if (query.trim().isEmpty) {
      setState(() {
        isSearching = false;
      });

      _loadFolder(navigationStack.last);
      return;
    }

    await searchProvider.search(query.trim());

    if (!mounted) return;

    // Converte resultados de busca para items
    final searchItems = <FolderItem>[];
    for (final result in searchProvider.results) {
      if (result.isFolder) {
        searchItems.add(
          FolderItemFolder(
            folder: FolderEntity(
              id: result.id,
              name: result.name,
              path: result.path,
            ),
            name: result.name,
            path: result.path,
          ),
        );
      } else {
        searchItems.add(
          FolderItemFile(
            file: FileEntity(
              id: result.id,
              name: result.name,
              path: result.path,
              size: 0,
              mimeType: 'application/octet-stream',
            ),
            name: result.name,
            path: result.path,
          ),
        );
      }
    }

    setState(() {
      isSearching = true;
      items = searchItems;
    });
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

    if (!mounted) return;

    final filesProvider = context.read<FilesProvider>();
    final success = await filesProvider.deleteFile(path);

    if (!mounted) return;

    if (success) {
      await _loadFolder(navigationStack.last);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Arquivo deletado com sucesso")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Erro ao deletar arquivo")));
    }
  }

  Future<void> _deleteFolder(String path) async {
    final foldersProvider = context.read<FoldersProvider>();
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
    final success = await foldersProvider.deleteFolder(path);

    if (!mounted) return;

    if (success) {
      await _loadFolder(navigationStack.last);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pasta deletada com sucesso")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Erro ao deletar Pasta")));
    }
  }

  void _createNewFolder() async {
    final foldersProvider = context.read<FoldersProvider>();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => const NewFolderDialog(),
    );

    if (result != null && result.trim().isNotEmpty) {
      final currentPath = navigationStack.last;
      // Obtém o ID da pasta atual do breadcrumb (última pasta na navegação)
      final currentFolderId = foldersProvider.currentFolder?.id;

      final success = await foldersProvider.createFolder(
        result.trim(),
        parentId: currentFolderId,
      );

      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                foldersProvider.errorMessage ?? "Erro ao criar pasta",
              ),
            ),
          );
        }
        return;
      }

      if (mounted) {
        await _loadFolder(currentPath);
      }

    }
  }

  void _openUploadDialog() {
    showDialog(
      context: context,
      builder: (_) => UploadDocumentDialog(currentPath: navigationStack.last),
    ).then((result) {
      if (result == true) {
        _loadFolder(navigationStack.last);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = Responsive.isMobile(context);
    final isDesktop = Responsive.isDesktop(context);
    final foldersProvider = context.watch<FoldersProvider>();
    final isLoading = foldersProvider.state == FoldersState.loading;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : AppConstants.defaultPadding),
        child: Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 1200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
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
                      color: theme.primaryColor.withValues(alpha: 0.05),
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
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  size: 18,
                                ),
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                    navigationStack.length > 1
                                        ? AppConstants.primaryColor.withValues(
                                            alpha: 0.1,
                                          )
                                        : Colors.grey.withValues(alpha: 0.1),
                                  ),
                                ),
                                onPressed: navigationStack.length > 1
                                    ? _goBack
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Wrap(
                                  children: List.generate(
                                    navigationStack.length,
                                    (index) {
                                      final folder =
                                          navigationStack[index].isEmpty
                                          ? "Home"
                                          : navigationStack[index]
                                                .split("/")
                                                .last;

                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                navigationStack =
                                                    navigationStack.sublist(
                                                      0,
                                                      index + 1,
                                                    );
                                              });
                                              _loadFolder(navigationStack.last);
                                            },
                                            child: Text(
                                              folder,
                                              style: TextStyle(
                                                color:
                                                    AppConstants.primaryColor,
                                                fontWeight: FontWeight.w500,
                                                fontSize: isMobile ? 14 : 16,
                                              ),
                                            ),
                                          ),
                                          if (index !=
                                              navigationStack.length - 1)
                                            const Text(" > "),
                                        ],
                                      );
                                    },
                                  ),
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
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : items.isEmpty
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
                                    if (isDesktop &&
                                        constraints.maxWidth > 800) {
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

  Widget _buildItem(FolderItem item) {
    switch (item) {
      case FolderItemFolder folderItem:
        return ItemFolder(
          folderName: folderItem.name,
          onTap: () => _openFolder(folderItem.path),
          onDeleteFolder: () => _deleteFolder(folderItem.path),
          onEditFolder: () {},
        );
      case FolderItemFile fileItem:
        return ItemFile(
          fileName: fileItem.name,
          onTap: () {},
          onDeleteFile: () => _deleteFile(fileItem.path),
          onDownloadFile: () => _download(fileItem.path),
          onMoverFile: () {},
        );
    }
  }
}
