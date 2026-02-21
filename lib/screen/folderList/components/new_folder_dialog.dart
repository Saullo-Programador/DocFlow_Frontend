import 'package:flutter/material.dart';
import 'package:manege_doc/constants.dart';
import 'package:manege_doc/responsive/responsive.dart';

class NewFolderDialog extends StatefulWidget {
  const NewFolderDialog({super.key});

  @override
  State<NewFolderDialog> createState() => _NewFolderDialogState();
}

class _NewFolderDialogState extends State<NewFolderDialog> {
  final TextEditingController folderController = TextEditingController();

  void _createFolder() {
    final name = folderController.text.trim();

    if (name.isEmpty) return;

    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = Responsive.isDesktop(context)
        ? 900.0
        : Responsive.isTablet(context)
        ? 700.0
        : MediaQuery.of(context).size.width * 0.95;

    //final dialogHeight = Responsive.isDesktop(context)
    //    ? 500.0
    //    : Responsive.isTablet(context)
    //    ? 450.0
    //    : MediaQuery.of(context).size.height * 0.7;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Criar Nova Pasta"),
      content: SizedBox(
        width: dialogWidth * 0.7,
        child: TextField(
          cursorColor: primaryColor,
          controller: folderController,
          textInputAction: TextInputAction.done, // mostra botão "done"
          autofocus: true,
          onSubmitted: (_) {
            _createFolder(); // ENTER cria a pasta
          },
          decoration: const InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            hintText: "Digite o nome da pasta",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
      ),
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
          onPressed: () {
            _createFolder();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: const Text("Criar", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
