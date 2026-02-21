import 'package:flutter/material.dart';
import 'package:manege_doc/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children:[
            Center(
              child: Text("Profile Screen"),
            )
          ],
        ),
      ),
    );
  }
}