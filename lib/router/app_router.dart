import 'package:go_router/go_router.dart';
import 'package:manege_doc/screen/dashboard/dashboard_screen.dart';
import 'package:manege_doc/screen/folderList/folder_screen.dart';
import 'package:manege_doc/screen/main/main_screen.dart';
import 'package:manege_doc/screen/profile/profile_screen.dart';
import 'package:manege_doc/screen/splash/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: "/splash",
  routes: [
    GoRoute(
      path: "/splash", 
      builder: (context, state) => const SplashScreen()
    ),
    GoRoute(
      path: "/",
      redirect: (context, state) => "/splash",
    ),
    // SHELL ROUTE - Layout principal
    ShellRoute(
      builder: (context, state, child) {
        return MainScreen(child: child);
      },
      routes: [
        GoRoute(
          path: "/dashboard",
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: "/folder",
          builder: (context, state) => const FolderScreen(),
        ),
        GoRoute(
          path: "/profile",
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);
