import 'package:flutter/material.dart';
import 'package:manege_doc/controller/menu_app_controller.dart';
import 'package:manege_doc/router/app_router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MenuAppController())
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
