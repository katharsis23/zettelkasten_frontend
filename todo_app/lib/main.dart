import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';

import 'pages/home_screen.dart';
import 'pages/login_screen.dart';
import 'pages/tasks_screen.dart';
import 'pages/notes_screen.dart';
import 'pages/user_screen.dart';
import 'pages/error_page.dart';

void main() {
  const bool debugMode = !bool.fromEnvironment('dart.vm.product');
  runApp(
    DevicePreview(
      enabled: debugMode,
      tools: const [...DevicePreview.defaultTools],
      builder: (context) => const ZettelkastenApp(),
    ),
  );
}

class ZettelkastenApp extends StatelessWidget {
  const ZettelkastenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zettelkasten',

      // Routes,
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (context) {
          switch (settings.name) {
            case '/':
              return HomeScreen();
            case '/login':
              return LoginPage();
            case '/tasks':
              return TasksScreen();
            case '/notes':
              return NotesScreen();
            case '/user':
              return UserScreen();
            default:
              return ErrorPage();
          }
        },
      ),
    );
  }
}
