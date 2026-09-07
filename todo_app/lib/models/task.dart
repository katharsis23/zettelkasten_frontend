import 'package:injectable/injectable.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class Task {
  String task_id;
  String title;
  String? description;
  DateTime created_at;
  DateTime? appointed_at;

  Task({
    required this.task_id,
    required this.title,
    this.description,
    required this.created_at,
    this.appointed_at,
  });

  static DateTime _parseDate(dynamic value) {
    if (value == null) {
      throw ArgumentError('Date value is null');
    }
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);

    final dynamic maybeToDate = (value as dynamic);
    try {
      final dt = maybeToDate.toDate();
      if (dt is DateTime) return dt;
    } catch (_) {}

    throw ArgumentError('Unsupported date value type: ${value.runtimeType}');
  }

  factory Task.fromJSON(Map<String, dynamic> json) {
    return Task(
      task_id: json['task_id'],
      title: json['title'],
      description: json['description'] ?? null,
      created_at: _parseDate(json['created_at']),
      appointed_at: json['appointed_at'] != null
          ? _parseDate(json['appointed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'title': title,
      'description': description,
      'appointed_at': appointed_at?.toIso8601String(),
    };
  }

  Map<String, dynamic> toCacheJSON() {
    return {
      'task_id': task_id,
      'title': title,
      'description': description,
      'created_at': created_at.toIso8601String(),
      'appointed_at': appointed_at?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.task_id == task_id;
  }

  @override
  int get hashCode => task_id.hashCode;
}

@singleton
class TaskSet {
  final Set<Task> tasks;
  String check_sum;

  TaskSet({required this.tasks}) : check_sum = _computeChecksum(tasks);

  static String _computeChecksum(Iterable<Task> tasks) {
    final list = tasks.toList()..sort((a, b) => a.task_id.compareTo(b.task_id));

    String formatBackendDate(DateTime dt) {
      final utc = dt.toUtc();
      // Python datetime.isoformat() with microsecond=0 omits fractional seconds.
      // Backend also uses UTC and prints timezone as +00:00.
      String two(int v) => v.toString().padLeft(2, '0');
      final y = utc.year.toString().padLeft(4, '0');
      final m = two(utc.month);
      final d = two(utc.day);
      final hh = two(utc.hour);
      final mm = two(utc.minute);
      final ss = two(utc.second);
      return '$y-$m-${d}T$hh:$mm:$ss+00:00';
    }

    // Backend hashes JSON with sort_keys=True. Dart preserves insertion order,
    // so we insert keys in lexicographic order to match.
    final normalized = list
        .map(
          (t) => <String, dynamic>{
            'appointed_at': t.appointed_at != null
                ? formatBackendDate(t.appointed_at!)
                : null,
            'created_at': formatBackendDate(t.created_at),
            'description': t.description,
            'task_id': t.task_id,
            'title': t.title,
          },
        )
        .toList(growable: false);

    final bytes = utf8.encode(jsonEncode(normalized));
    return sha256.convert(bytes).toString();
  }

  String recomputeChecksum() {
    check_sum = _computeChecksum(tasks);
    return check_sum;
  }

  void add(Task task) {
    tasks.add(task);
    recomputeChecksum();
  }

  void remove(Task task) {
    tasks.remove(task);
    recomputeChecksum();
  }

  Iterable<Task> getTasks() {
    return [...tasks];
  }

  Task? getTask(String taskId) {
    final task = tasks.firstWhere((task) => task.task_id == taskId);
    return task;
  }
}
