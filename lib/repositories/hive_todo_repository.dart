import 'package:hive/hive.dart';
import '../models/todo_model.dart';
import 'todo_repository.dart';

class HiveTodoRepository implements TodoRepository {
  final Box<TodoModel> _box = Hive.box<TodoModel>('todos');

  void _cleanExpiredTodos() {
    final now = DateTime.now();

    for (var todo in _box.values.toList()) {
      if (todo.isDone && todo.completedAt != null) {
        final difference = now.difference(todo.completedAt!);

        if (difference.inHours >= 24) {
          _box.delete(todo.id);
        }
      }
    }
  }

  @override
  List<TodoModel> getTodos() {
    _cleanExpiredTodos();

    final todos = _box.values.toList();

    // Unfinished first, newest first inside each group
    todos.sort((a, b) {
      if (a.isDone == b.isDone) {
        return b.createdAt.compareTo(a.createdAt);
      }
      return a.isDone ? 1 : -1;
    });

    return todos;
  }

  @override
  void addTodo(TodoModel todo) {
    _box.put(todo.id, todo);
  }

  @override
  void updateTodo(String id, bool isDone) {
    final todo = _box.get(id);

    if (todo != null) {
      todo.isDone = isDone;

      if (isDone) {
        todo.completedAt = DateTime.now();
      } else {
        todo.completedAt = null;
      }

      todo.save();
    }
  }

  @override
  void deleteTodo(String id) {
    _box.delete(id);
  }
}