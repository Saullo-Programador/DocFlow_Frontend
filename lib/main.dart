import 'package:flutter/material.dart';
import 'package:manege_doc/controller/menu_app_controller.dart';
import 'package:manege_doc/router/app_router.dart';
import 'package:provider/provider.dart';

import 'core/di/injection.dart';
import 'features/auth/presentation/providers/auth_provider.dart'; 
import 'features/files/presentation/providers/files_provider.dart';
import 'features/folders/presentation/providers/folders_provider.dart';
import 'features/history/presentation/providers/history_provider.dart';
import 'features/search/presentation/providers/search_provider.dart';
import 'features/users/presentation/providers/users_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Controller existente
        ChangeNotifierProvider(create: (context) => MenuAppController()),

        // Providers da nova arquitetura Clean Architecture
        ChangeNotifierProvider(create: (_) => sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => sl<FilesProvider>()),
        ChangeNotifierProvider(create: (_) => sl<FoldersProvider>()),
        ChangeNotifierProvider(create: (_) => sl<HistoryProvider>()),
        ChangeNotifierProvider(create: (_) => sl<SearchProvider>()),
        ChangeNotifierProvider(create: (_) => sl<UsersProvider>()),
      ],
      child: MaterialApp.router(
        title: 'DocFlow',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
