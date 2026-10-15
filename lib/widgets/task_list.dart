import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final ValueChanged<Task> onDelete, onEdit, onToggle;
  const TaskList({
    super.key,
    required this.tasks,
    required this.onDelete,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.checklist, size: 64, color: Colors.indigo),
            SizedBox(height: 16),
            Text('No tasks here yet', style: TextStyle(fontSize: 22)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: tasks.length,
      separatorBuilder: (_, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final task = tasks[index];
        final completed = task.status == TaskStatus.completed;
        final color = completed ? Colors.blue : Colors.green;
        return Material(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: completed,
                  shape: const CircleBorder(),
                  side: BorderSide(
                    color: completed ? Colors.blue : Colors.grey.shade400,
                    width: 1.5,
                  ),
                  fillColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? Colors.blue
                        : Colors.white,
                  ),
                  checkColor: Colors.white,
                  semanticLabel: completed
                      ? 'Mark ${task.title} pending'
                      : 'Complete ${task.title}',
                  onChanged: (_) => onToggle(task),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Tooltip(
                    message: 'Edit task details',
                    child: InkWell(
                      onTap: () => onEdit(task),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                decoration: completed
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: completed
                                    ? Colors.blueGrey
                                    : const Color(0xff14283e),
                              ),
                            ),
                            if (task.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                task.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                completed ? 'Completed' : 'Pending',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: color.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Edit task',
                  onPressed: () => onEdit(task),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: Colors.blueGrey,
                  ),
                ),

                IconButton(
                  tooltip: 'Delete task',
                  onPressed: () => onDelete(task),
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
