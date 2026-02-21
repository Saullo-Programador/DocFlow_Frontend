import 'package:flutter/material.dart';
import 'package:manege_doc/constants.dart';

class DocScreen extends StatelessWidget {
  const DocScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Center(
              child: Text(
                "${MediaQuery.of(context).size.width < 600 ? "Mobile" 
                : MediaQuery.of(context).size.width > 1200 ? "Desktop" 
                : "Tablet"} Layout"
              ),
            )
          ],
        ),
      )
    );
  }
}