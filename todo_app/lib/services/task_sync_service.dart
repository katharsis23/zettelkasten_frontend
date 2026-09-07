import 'package:injectable/injectable.dart';

import '../api/tasks.dart';
import '../cache/task_cache.dart';
import '../models/task.dart';

@singleton
class TaskSyncService {
  Future<TaskSet> loadFromCache() async {
    final cached = await TaskCache.getTasks();
    return TaskSet(tasks: cached.toSet());
  }

  Future<bool> syncIfNeeded(TaskSet current) async {
    final remoteChecksum = await TasksApi.getRemoteChecksum();

    // If meta endpoint is not implemented yet, just do a full refresh.
    if (remoteChecksum == null) {
      final remoteTasks = await TasksApi.getAllTasks();
      await TaskCache.replaceAll(TaskSet(tasks: remoteTasks.toSet()));
      current.tasks
        ..clear()
        ..addAll(remoteTasks);
      current.recomputeChecksum();
      return true;
    }

    final localChecksum = current.recomputeChecksum();
    if (remoteChecksum == localChecksum) {
      return false;
    }

    final remoteTasks = await TasksApi.getAllTasks();
    await TaskCache.replaceAll(TaskSet(tasks: remoteTasks.toSet()));
    current.tasks
      ..clear()
      ..addAll(remoteTasks);
    current.recomputeChecksum();
    return true;
  }
}
