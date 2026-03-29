import 'package:go_router/go_router.dart';
import 'package:manege_doc/screen/dashboard/dashboard_screen.dart';
import 'package:manege_doc/screen/folderList/folder_screen.dart';
import 'package:manege_doc/screen/forgotPassword/forgot_password_screen.dart';
import 'package:manege_doc/screen/forgotPassword/reset_password_screen.dart';
import 'package:manege_doc/screen/forgotPassword/verification_code_screen.dart';
import 'package:manege_doc/screen/login/login_screen.dart';
import 'package:manege_doc/screen/main/main_screen.dart';
import 'package:manege_doc/screen/profile/profile_screen.dart';
import 'package:manege_doc/screen/register/register_screen.dart';
import 'package:manege_doc/screen/settings/settings_screen.dart';
import 'package:manege_doc/screen/splash/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: "/splash",
  routes: [
    GoRoute(path: "/splash", builder: (context, state) => const SplashScreen()),
    GoRoute(path: "/", redirect: (context, state) => "/splash"),
    // --- Rotas de Autenticação (Fora do ShellRoute) ---
    GoRoute(path: "/login", builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: "/register",
      builder: (context, state) => const RegisterScreen(),
    ),

    GoRoute(
      path: "/forgot-password",
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: "/verification-code",
      builder: (context, state) => VerificationCodeScreen(),
    ),
    GoRoute(
      path: "/reset-password",
      builder: (context, state) => const ResetPasswordScreen(),
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
          path: "/settings",
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: "/profile",
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);
