import '../models/task.dart';
import 'task_db.dart';

class TaskCache {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await TaskDb.init();
    _initialized = true;
  }

  static Future<List<Task>> getTasks() async {
    await init();
    return await TaskDb.getAllTasks();
  }

  static Future<void> replaceAll(TaskSet taskSet) async {
    await init();
    await TaskDb.replaceAllTasks(taskSet.getTasks());
  }

  static Future<void> upsertAll(Iterable<Task> tasks) async {
    await init();
    await TaskDb.upsertTasks(tasks);
  }

  static Future<void> deleteById(String taskId) async {
    await init();
    await TaskDb.deleteTaskById(taskId);
  }
}
