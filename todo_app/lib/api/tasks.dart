import 'package:dio/dio.dart';
import 'client.dart';
import '../models/task.dart';
import '../services/token_service.dart';

class TasksApi {
  static Future<String?> getRemoteChecksum() async {
    final token = await TokenService.getToken();
    if (token == null) return null;

    try {
      final response = await dio.get(
        '/tasks/meta/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map;
        final checksum = data['checksum'];
        return checksum is String ? checksum : null;
      }
      return null;
    } on DioException {
      return null;
    }
  }

  static Future<List<Task>> getAllTasks({int pageSize = 100}) async {
    final token = await TokenService.getToken();
    if (token == null) {
      throw Exception('No access token');
    }

    final tasks = <Task>[];
    int page = 1;

    while (true) {
      final response = await dio.get(
        '/task',
        queryParameters: {'page': page, 'size': pageSize},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final data = response.data;
      if (data is! Map) {
        throw Exception('Unexpected response type');
      }

      final list = data['tasks'];
      if (list is List) {
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            tasks.add(Task.fromJSON(item));
          } else if (item is Map) {
            tasks.add(Task.fromJSON(Map<String, dynamic>.from(item)));
          }
        }
      }

      final pagination = data['pagination'];
      final hasNext = pagination is Map ? pagination['has_next'] : null;
      if (hasNext is bool && hasNext) {
        page += 1;
        continue;
      }
      break;
    }

    return tasks;
  }

  static Future<Task?> postTask(Task task) async {
    try {
      final token = await TokenService.getToken();
      final body = task.toJSON();
      final response = await dio.post(
        '/task/',
        data: body,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 201 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;

        // Server provides complete task data, use Task.fromJSON directly
        return Task.fromJSON(data);
      }
      return null;
    } catch (e) {
      throw Exception('Couldnt upload task: $e');
    }
  }
}
