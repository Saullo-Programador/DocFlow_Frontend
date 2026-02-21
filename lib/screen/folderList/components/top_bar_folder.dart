import 'package:flutter/material.dart';
import 'package:manege_doc/responsive/responsive.dart';

class TopBarFolder extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onNewFolder;
  final VoidCallback onUploadDocument;

  const TopBarFolder({
    super.key,
    required this.searchController,
    required this.onNewFolder,
    required this.onUploadDocument,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildSearchField()),

          const SizedBox(width: 12),

          if (isDesktop) ...[
            _buildNewFolderButton(),
            const SizedBox(width: 10),
            _buildUploadDocumentButton(),
          ] else
            _buildMobileActions(context),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: "Pesquisar documentos...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.withValues(alpha: 0.1),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildNewFolderButton() {
    return ElevatedButton.icon(
      onPressed: onNewFolder,
      icon: const Icon(Icons.create_new_folder),
      label: const Text("Nova Pasta"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildUploadDocumentButton() {
    return ElevatedButton.icon(
      onPressed: onUploadDocument,
      icon: const Icon(Icons.note_add),
      label: const Text("Upload Documento"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildMobileActions(BuildContext context) {
    return PopupMenuButton<String>(
      borderRadius: BorderRadius.circular(12),
      icon: const Icon(Icons.add),
      onSelected: (value) {
        if (value == 'folder') {
          onNewFolder();
        } else if (value == 'document') {
          onUploadDocument();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'folder',
          child: ListTile(
            leading: Icon(Icons.create_new_folder, color: Colors.blue),
            title: Text("Nova Pasta"),
          ),
        ),
        const PopupMenuItem(
          value: 'document',
          child: ListTile(
            leading: Icon(Icons.note_add, color: Colors.green),
            title: Text("Upload Documento"),
          ),
        ),
      ],
    );
  }
}
