import 'package:injectable/injectable.dart';
import 'package:get_it/get_it.dart';
import 'injection.config.dart';
import 'models/task.dart';
import 'services/task_sync_service.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  getIt.init();

  if (!getIt.isRegistered<TaskSet>()) {
    getIt.registerSingleton<TaskSet>(TaskSet(tasks: <Task>{}));
  }
  if (!getIt.isRegistered<TaskSyncService>()) {
    getIt.registerSingleton<TaskSyncService>(TaskSyncService());
  }
}
