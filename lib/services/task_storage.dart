import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class TaskStorage {
  Future<List<Task>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('todo_tasks_v1');
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => Task.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> save(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final success = await prefs.setString(
      'todo_tasks_v1',
      jsonEncode(tasks.map((t) => t.toJson()).toList()),
    );
    if (!success) throw StateError('Could not save tasks');
  }
}
