// lib/models/todo_model.dart
import 'package:hive/hive.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 0)
class TodoModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool isDone;

  @HiveField(3)
  DateTime? completedAt;

  @HiveField(4)
  final DateTime createdAt;

  // 🆕 New field for scheduling
  @HiveField(5)
  DateTime? dueDate;

  // 🆕 Bool flag indicating whether a due date/time is set
  @HiveField(6)
  bool isdate_set;

  TodoModel({
    required this.id,
    required this.title,
    this.isDone = false,
    this.completedAt,
    DateTime? createdAt,
    this.dueDate, // pass due date when creating
    bool? isdate_set, // optional override; otherwise derived from dueDate
  })  : createdAt = createdAt ?? DateTime.now(),
        isdate_set = isdate_set ?? (dueDate != null);
}
