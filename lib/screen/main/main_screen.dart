import 'package:flutter/material.dart';
import 'package:manege_doc/controller/menu_app_controller.dart';
import 'package:manege_doc/responsive/responsive.dart';
import 'package:manege_doc/screen/main/components/side_menu.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<MenuAppController>();

    return Scaffold(
      key: controller.scaffoldKey,
      drawer: SizedBox(width: 100, child: SideMenu()),
      appBar: !Responsive.isDesktop(context)
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  controller.controlMenu();
                },
                icon: const Icon(Icons.menu, color: Colors.black),
              ),
            )
          : const PreferredSize(
              preferredSize: Size.zero,
              child: SizedBox(),
            ),
      body: SafeArea( 
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              Expanded(flex: 1, child: SideMenu()),
            Expanded(flex: 5, child: child),
          ],
        ),
      ),
    );
  }
}
