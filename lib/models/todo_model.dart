import 'package:hive/hive.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 0)
class TodoModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  bool isDone;

  @HiveField(3)
  DateTime? completedAt;

  @HiveField(4)
  DateTime createdAt;

  TodoModel({
    required this.id,
    required this.title,
    this.isDone = false,
    this.completedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}