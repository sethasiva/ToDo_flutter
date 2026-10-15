import 'package:flutter/material.dart';

import '../models/task.dart';
import 'task_count_card.dart';

class Dashboard extends StatelessWidget {
  final List<Task> tasks;
  final String name, email;
  final VoidCallback onAdd, onProfile;
  final ValueChanged<TaskStatus?> onFilter;
  const Dashboard({
    super.key,
    required this.tasks,
    required this.name,
    required this.email,
    required this.onAdd,
    required this.onProfile,
    required this.onFilter,
  });
  int count(TaskStatus status) => tasks.where((t) => t.status == status).length;
  Widget card(String title, int count, Color color, TaskStatus? status) =>
      Semantics(
        button: true,
        label: 'Show $title',
        child: InkWell(
          onTap: () => onFilter(status),
          borderRadius: BorderRadius.circular(12),
          child: TaskCountCard(title: title, count: count, color: color),
        ),
      );
  @override
  Widget build(BuildContext context) {
    final completed = count(TaskStatus.completed);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: onProfile,
          leading: const CircleAvatar(
            radius: 28,
            child: Icon(Icons.person, size: 32),
          ),
          title: Text(
            name.isEmpty ? 'Hello!' : 'Hello, $name!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(email.isEmpty ? 'Tap to set up your profile' : email),
          trailing: const Icon(Icons.edit_outlined),
        ),
        const SizedBox(height: 24),
        const Text(
          'Your task overview',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        card('Total tasks', tasks.length, Colors.indigo, null),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: card(
                'Pending',
                count(TaskStatus.pending),
                Colors.green,
                TaskStatus.pending,
              ),
            ),
            Expanded(
              child: card(
                'Completed',
                completed,
                Colors.blue,
                TaskStatus.completed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        LinearProgressIndicator(
          value: tasks.isEmpty ? 0 : completed / tasks.length,
          minHeight: 8,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 8),
        Text('$completed of ${tasks.length} tasks completed'),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Add new task'),
        ),
      ],
    );
  }
}
