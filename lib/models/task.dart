enum TaskStatus { pending, completed }

class Task {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'status': status.name,
  };
  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    status: json['status'] == 'active'
        ? TaskStatus.pending
        : TaskStatus.values.byName(json['status'] as String),
  );
}
