import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/services/task_storage.dart';
import 'package:todo_app/screens/home_screen.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'Tasks preserve identity, description and status across reloads',
    () async {
      final storage = TaskStorage();
      const task = Task(
        id: '1',
        title: 'Study',
        description: 'Flutter',
        status: TaskStatus.pending,
      );
      await storage.save([task]);
      var loaded = await TaskStorage().load();
      expect(loaded.single.id, '1');
      expect(loaded.single.description, 'Flutter');
      expect(loaded.single.status, TaskStatus.pending);
      await storage.save([
        Task(
          id: task.id,
          title: 'Done',
          description: '',
          status: TaskStatus.completed,
        ),
      ]);
      loaded = await TaskStorage().load();
      expect(loaded.single.title, 'Done');
      expect(loaded.single.status, TaskStatus.completed);
      await storage.save([]);
      expect(await TaskStorage().load(), isEmpty);
    },
  );
  test('Legacy active tasks become pending without losing details', () {
    final task = Task.fromJson({
      'id': 'legacy',
      'title': 'Keep me',
      'description': 'Saved details',
      'status': 'active',
    });
    expect(task.status, TaskStatus.pending);
    expect(task.title, 'Keep me');
    expect(task.description, 'Saved details');
  });
  testWidgets('Create, edit, cancel deletion, delete and persist', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Add new task'), 200);
    await tester.tap(find.text('Add new task'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save task'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a task title'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'Read a book');
    await tester.enterText(find.byType(TextFormField).at(1), 'Chapter one');
    await tester.ensureVisible(find.text('Save task'));
    await tester.tap(find.text('Save task'));
    await tester.pumpAndSettle();
    expect((await TaskStorage().load()).single.title, 'Read a book');
    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();
    expect(find.text('Read a book'), findsOneWidget);
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect((await TaskStorage().load()).single.status, TaskStatus.completed);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    expect(find.text('Task completed! Great job!'), findsOneWidget);
    expect(
      tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor,
      const Color(0xff10b981),
    );
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect((await TaskStorage().load()).single.status, TaskStatus.pending);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
    await tester.tap(find.byTooltip('Edit task'));
    await tester.pumpAndSettle();
    expect(find.text('Read a book'), findsOneWidget);
    expect(find.text('Chapter one'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'Read two books');
    expect(find.byType(DropdownButtonFormField<TaskStatus>), findsNothing);
    await tester.ensureVisible(find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect((await TaskStorage().load()).single.status, TaskStatus.pending);
    expect(find.text('Read two books'), findsOneWidget);
    await tester.tap(find.byTooltip('Delete task'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Read two books'), findsOneWidget);
    await tester.tap(find.byTooltip('Delete task'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('No tasks here yet'), findsOneWidget);
    expect(await TaskStorage().load(), isEmpty);
  });
}
