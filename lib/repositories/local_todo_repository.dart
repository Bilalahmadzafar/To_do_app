// lib/repositories/local_todo_repository.dart
import 'package:to_do_list/models/todo_model.dart';
import 'todo_repository.dart';

class LocalTodoRepository implements TodoRepository {
  final List<TodoModel> _todos = [];

  @override
  List<TodoModel> getTodos() {
    // Return a sorted copy: unfinished first, newest first inside each group
    final todos = List<TodoModel>.from(_todos);
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
    _todos.add(todo);
  }

  @override
  void updateTodo(String id, bool isDone) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index].isDone = isDone;
      if (isDone) {
        _todos[index].completedAt = DateTime.now();
      } else {
        _todos[index].completedAt = null;
      }
    }
  }

  @override
  void deleteTodo(String id) {
    _todos.removeWhere((todo) => todo.id == id);
  }

  /// NEW: Update the title of an existing todo
  @override
  void updateTodoTitle(String id, String newTitle) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index].title = newTitle;
    }
  }
}
