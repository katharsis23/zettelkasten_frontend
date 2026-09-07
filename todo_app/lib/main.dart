import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'pages/home_screen.dart';
import 'pages/login_screen.dart';
import 'pages/tasks_screen.dart';
import 'pages/notes_screen.dart';
import 'pages/user_screen.dart';
import 'pages/task_details_screen.dart';
import 'pages/add_task_screen.dart';
import 'pages/error_page.dart';
import 'injection.dart';
import 'cache/avatar_cache.dart';
import 'cache/task_cache.dart';
import 'models/task.dart';
import 'services/task_sync_service.dart';
import 'services/user_cache_service.dart';

// import 'api/healthcheck.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // Initialize dependency injection
  await configureDependencies();

  // Initialize avatar cache
  await AvatarCache.init();

  // Initialize task cache (SQLite)
  await TaskCache.init();

  // Warm up in-memory TaskSet from local cache (fast, offline-first)
  final taskSet = getIt<TaskSet>();
  final cachedTasks = await TaskCache.getTasks();
  taskSet.tasks
    ..clear()
    ..addAll(cachedTasks);
  taskSet.recomputeChecksum();

  // Background sync with backend (non-blocking)
  Future(() async {
    try {
      await getIt<TaskSyncService>().syncIfNeeded(taskSet);
    } catch (_) {}
  });

  // Background avatar prefetch (non-blocking)
  Future(() async {
    try {
      await UserCacheService.getAvatarUrl();
    } catch (_) {}
  });

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
              return const HomeScreen();
            case '/login':
              return const LoginPage();
            case '/tasks':
              return const TasksScreen();
            case '/notes':
              return const NotesScreen();
            case '/user':
              return const UserScreen();
            case '/task-details':
              final taskId = settings.arguments as String?;
              if (taskId == null) {
                return const ErrorPage();
              }
              return TaskDetailsScreen(taskId: taskId);
            case '/add-task':
              return const AddTaskScreen();
            default:
              return const ErrorPage();
          }
        },
      ),
    );
  }
}
