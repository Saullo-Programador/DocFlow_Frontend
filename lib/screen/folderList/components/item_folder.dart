import 'package:flutter/material.dart';

class ItemFolder extends StatelessWidget {
  final String folderName;
  final VoidCallback? onTap;
  final VoidCallback onDeleteFolder;
  final VoidCallback onEditFolder;
  const ItemFolder({super.key, this.folderName = "Nome da Pasta", required this.onDeleteFolder, required this.onEditFolder, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        excludeFromSemantics: true,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
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
              Row(
                children: [
                  Icon(Icons.folder, size: 30, color: Colors.blueAccent),
                  SizedBox(width: 8),
                  Text(folderName),
                ],
              ),
              Spacer(),
              
              _buildMobileActions(context)
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildMobileActions(BuildContext context) {
    return PopupMenuButton<String>(
      borderRadius: BorderRadius.circular(12),
      icon: const Icon(Icons.more_vert, color: Colors.grey),
      onSelected: (value) {
        if (value == 'Editar') {
          onEditFolder();
        } else if (value == 'Excluir') {
          onDeleteFolder();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'Editar',
          child: ListTile(
            leading: Icon(Icons.edit, color: Colors.blue),
            title: Text("Editar"),
          ),
        ),
        const PopupMenuItem(
          value: 'Excluir',
          child: ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text("Excluir"),
          ),
        ),
      ],
    );
  }
}

