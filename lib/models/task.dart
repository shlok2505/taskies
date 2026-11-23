import 'package:cloud_firestore/cloud_firestore.dart';

enum Priority { low, medium, high }

class Task {
  final String id;
  final String title;
  final String description;
  final Priority priority;
  final DateTime dueDate;
  final bool isCompleted;

  const Task({
    this.id = '',
    required this.title,
    this.description = '',
    this.priority = Priority.medium,
    required this.dueDate,
    this.isCompleted = false,
  });

  factory Task.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Task(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      priority: Priority.values.byName(d['priority'] ?? 'medium'),
      dueDate: (d['dueDate'] as Timestamp).toDate(),
      isCompleted: d['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'priority': priority.name,
    'dueDate': Timestamp.fromDate(dueDate),
    'isCompleted': isCompleted,
  };
}
