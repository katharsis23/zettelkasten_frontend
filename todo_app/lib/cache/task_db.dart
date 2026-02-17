import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
//import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;

import '../models/task.dart';

class TaskDb {
  static const _dbName = 'tasks.db';
  static const _dbVersion = 1;

  static Database? _db;

  static Future<void> init() async {
    if (_db != null) return;

    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, _dbName);

    _db = await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE tasks('
          'task_id TEXT PRIMARY KEY,'
          'title TEXT NOT NULL,'
          'description TEXT NULL,'
          'created_at TEXT NOT NULL,'
          'appointed_at TEXT NULL'
          ')',
        );
      },
    );
  }

  static Future<Database> _database() async {
    await init();
    final db = _db;
    if (db == null) {
      throw StateError('TaskDb was not initialized');
    }
    return db;
  }

  static Future<List<Task>> getAllTasks() async {
    final db = await _database();
    final rows = await db.query('tasks');
    return rows
        .map(
          (r) => Task.fromJSON({
            'task_id': r['task_id'],
            'title': r['title'],
            'description': r['description'],
            'created_at': r['created_at'],
            'appointed_at': r['appointed_at'],
          }),
        )
        .toList(growable: false);
  }

  static Future<void> upsertTasks(Iterable<Task> tasks) async {
    final db = await _database();
    final batch = db.batch();
    for (final t in tasks) {
      batch.insert('tasks', {
        'task_id': t.task_id,
        'title': t.title,
        'description': t.description,
        'created_at': t.created_at.toIso8601String(),
        'appointed_at': t.appointed_at?.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  static Future<void> replaceAllTasks(Iterable<Task> tasks) async {
    final db = await _database();
    await db.transaction((txn) async {
      await txn.delete('tasks');
      final batch = txn.batch();
      for (final t in tasks) {
        batch.insert('tasks', {
          'task_id': t.task_id,
          'title': t.title,
          'description': t.description,
          'created_at': t.created_at.toIso8601String(),
          'appointed_at': t.appointed_at?.toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    });
  }

  static Future<void> deleteTaskById(String taskId) async {
    final db = await _database();
    await db.delete('tasks', where: 'task_id = ?', whereArgs: [taskId]);
  }

  static Future<void> close() async {
    final db = _db;
    _db = null;
    if (db != null) {
      await db.close();
    }
  }
}
