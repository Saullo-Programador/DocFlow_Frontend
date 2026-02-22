import 'package:flutter/material.dart';
import 'package:manege_doc/api/api.dart';
import 'package:manege_doc/constants.dart';
import 'package:manege_doc/models/Item_model.dart';
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
    super.dispose();
  }

  String currentPath = ""; // raiz = documents
  List<ItemModel> items = [];

  List<String> navigationStack = [""];

  @override
  void initState() {
    super.initState();
    _loadFolder("");
  }

  Future<void> _loadFolder(String path) async {
    final folderContent = await Api().getFolderContent(path);

    if(!mounted) return;

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

  void _download(String path){
    Api().download(path);
  }

  void _deleteFolder(int index) {
    setState(() {
      items.removeAt(index);
    });
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            TopBarFolder(
              searchController: searchController,
              onUploadDocument: _openUploadDialog,
              onNewFolder: _createNewFolder,
            ),
            const SizedBox(height: 20),

            //! <--- NavigationStack --->
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        navigationStack.length > 1
                            ? primaryColor.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                      ),
                    ),
                    onPressed: navigationStack.length > 1 ? _goBack : null,
                  ),
                  SizedBox(width: 10),
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
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
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

            //! <--- Linha separadora --->
            const Divider(thickness: 1),

            const SizedBox(height: 16),

            Expanded(
              child: items.isEmpty
                  //! <--- Texto "Nenhum item encontrado" --->
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

                    //! <--- Lista de Pastas e Arquivos --->

                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];

                        //! <--- Item Pasta  --->
                        if (item.type == ItemType.folder) {
                          return ItemFolder(
                            folderName: item.name,
                            onTap: () => _openFolder(item.path),
                            onDeleteFolder: () => _deleteFolder(index),
                            onEditFolder: () {},
                          );
                        }

                        //! <--- Item Arquivo --->
                        return ItemFile(
                          fileName: item.name,
                          onTap: () {
                            
                          }, 
                          onDeleteFile: () {  }, 
                          onDownloadFile: () => _download(item.path), 
                          onMoverFile: () {  },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
