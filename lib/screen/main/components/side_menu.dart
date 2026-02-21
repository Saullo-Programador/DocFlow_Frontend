import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manege_doc/responsive/responsive.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return Drawer(
      elevation: 0,
      child: Container(
        decoration: _buildContainerDecoration(),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: _buildMenuItems(context, location),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context, String location) {
    return [
      DrawerListTile(
        title: "Dashboard",
        icon: Icons.dashboard_rounded,
        isSelected: location == "/dashboard",
        press: () => context.go("/dashboard"),
      ),
      DrawerListTile(
        title: "Folders",
        icon: Icons.folder_rounded,
        isSelected: location == "/folder",
        press: () => context.go("/folder"),
      ),
      DrawerListTile(
        title: "Profile",
        icon: Icons.person_rounded,
        isSelected: location == "/profile",
        press: () => context.go("/profile"),
      ),
    ];
  }

  BoxDecoration _buildContainerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.5),
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}


class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    super.key,
    required this.title,
    required this.icon,
    required this.press,
    this.isSelected = false,
  });

  final String title;
  final IconData icon;
  final VoidCallback press;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: press,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: _buildItemDecoration(),
          child: Row(
            mainAxisAlignment: isDesktop
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              _buildIcon(),
              if (isDesktop) _buildTitle(),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildItemDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: isSelected
          ? Colors.blue.withValues(alpha: 0.12)
          : Colors.transparent,
    );
  }

  Widget _buildIcon() {
    return Icon(
      icon,
      size: 22,
      color: isSelected ? Colors.blue : Colors.black54,
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight:
              isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? Colors.blue : Colors.black87,
        ),
      ),
    );
  }
}
