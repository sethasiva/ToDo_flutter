import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import '../services/task_storage.dart';
import '../widgets/dashboard.dart';
import '../widgets/task_list.dart';
import '../widgets/task_message.dart';
import 'add_task_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = TaskStorage();
  List<Task> _tasks = [];
  int _tab = 0;
  TaskStatus? _filter;
  String _name = '', _email = '';
  bool _loading = true, _saving = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tasks = await _storage.load();
      final prefs = await SharedPreferences.getInstance();
      final profile = prefs.getStringList('todo_profile');
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _name = profile?[0] ?? '';
        _email = profile?[1] ?? '';
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not load saved data. Please try again.';
        });
      }
    }
  }

  void _message(String text) => showTaskMessage(context, text);
  Future<void> _commit(List<Task> next, String message) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await _storage.save(next);
      if (!mounted) return;
      setState(() => _tasks = next);
      _message(message);
    } catch (_) {
      if (mounted) _message('Could not save changes. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _edit([Task? original]) async {
    final task = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (_) => AddTaskScreen(task: original)),
    );
    if (!mounted || task == null) return;
    await _commit(
      original == null
          ? [..._tasks, task]
          : _tasks.map((t) => t.id == task.id ? task : t).toList(),
      original == null ? 'Task added' : 'Task updated',
    );
  }

  Future<void> _toggle(Task task) async {
    final updated = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status == TaskStatus.completed
          ? TaskStatus.pending
          : TaskStatus.completed,
    );
    await _commit(
      _tasks.map((t) => t.id == task.id ? updated : t).toList(),
      updated.status == TaskStatus.completed
          ? 'Task completed! Great job!'
          : 'Task marked pending',
    );
  }

  Future<void> _delete(Task task) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('Delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted || yes != true) return;
    await _commit(
      _tasks.where((t) => t.id != task.id).toList(),
      'Task deleted',
    );
  }

  Future<void> _profile() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(name: _name, email: _email),
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      _name = result[0];
      _email = result[1];
    });
  }

  void _showTasks(TaskStatus? status) => setState(() {
    _tab = 1;
    _filter = status;
  });
  void _summary() {
    final pending = _tasks.where((t) => t.status == TaskStatus.pending).length;
    final completed = _tasks
        .where((t) => t.status == TaskStatus.completed)
        .length;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Task summary',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                '$pending pending tasks\n$completed completed tasks',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 12),
              const Text('Finish a task by editing its status to Completed.'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(_tab == 0 ? 'Todo App' : 'Task list'),
      leading: _tab == 1
          ? IconButton(
              tooltip: 'Back to Home',
              onPressed: () => setState(() => _tab = 0),
              icon: const Icon(Icons.arrow_back),
            )
          : null,
      actions: [
        IconButton(
          tooltip: 'Task summary',
          onPressed: _loading || _error != null ? null : _summary,
          icon: const Icon(Icons.notifications_none),
        ),
      ],
    ),
    body: SafeArea(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!),
                  TextButton(onPressed: _load, child: const Text('Retry')),
                ],
              ),
            )
          : AbsorbPointer(
              absorbing: _saving,
              child: Column(
                children: [
                  if (_saving) const LinearProgressIndicator(),
                  Expanded(
                    child: _tab == 0
                        ? Dashboard(
                            tasks: _tasks,
                            name: _name,
                            email: _email,
                            onAdd: () => _edit(),
                            onProfile: _profile,
                            onFilter: _showTasks,
                          )
                        : Column(
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Row(
                                  children: [
                                    ChoiceChip(
                                      label: Text('All (${_tasks.length})'),
                                      selected: _filter == null,
                                      onSelected: (_) => _showTasks(null),
                                    ),
                                    ...TaskStatus.values.map(
                                      (s) => Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: ChoiceChip(
                                          label: Text(s.name),
                                          selected: _filter == s,
                                          onSelected: (_) => _showTasks(s),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: TaskList(
                                  tasks: _tasks
                                      .where(
                                        (t) =>
                                            _filter == null ||
                                            t.status == _filter,
                                      )
                                      .toList(),
                                  onDelete: _delete,
                                  onToggle: _toggle,
                                  onEdit: _edit,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
    ),
    floatingActionButton: _tab == 1 && !_loading && _error == null
        ? FloatingActionButton(
            onPressed: _saving ? null : () => _edit(),
            tooltip: 'Add task',
            child: const Icon(Icons.add),
          )
        : null,
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: (i) => setState(() {
        _tab = i;
        _filter = null;
      }),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(icon: Icon(Icons.list_alt), label: 'Tasks'),
      ],
    ),
  );
}
