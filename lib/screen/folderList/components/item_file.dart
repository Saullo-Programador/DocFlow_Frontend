import 'package:flutter/material.dart';
import 'package:manege_doc/constants.dart';

class ItemFile extends StatelessWidget {
  final String fileName;
  final Color fileColor;
  final VoidCallback? onTap;
  final VoidCallback onDeleteFile;
  final VoidCallback onDownloadFile;
  final VoidCallback onMoverFile;

  const ItemFile({
    super.key, 
    this.fileName = "Nome do Arquivo", 
    this.fileColor = primaryColor,
    required this.onDeleteFile, 
    required this.onDownloadFile, 
    required this.onMoverFile, 
    this.onTap
  });

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
                  Icon(Icons.insert_drive_file_rounded, size: 30, color: fileColor),
                  SizedBox(width: 8),
                  Text(fileName),
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
        if (value == 'Download') {
          onDownloadFile();
        } else if (value == 'Excluir') {
          onDeleteFile();
        } else if (value == 'Mover') {
          onMoverFile();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'Download',
          child: ListTile(
            leading: Icon(Icons.download, color: Colors.blue),
            title: Text("Download"),
          ),
        ),
        const PopupMenuItem(
          value: 'Mover',
          child: ListTile(
            leading: Icon(Icons.drive_file_move, color: Colors.orange),
            title: Text("Mover"),
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

