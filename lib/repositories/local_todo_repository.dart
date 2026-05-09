import 'package:to_do_list/models/todo_model.dart';
import 'todo_repository.dart';

class LocalTodoRepository implements TodoRepository {
  final List<TodoModel> _todos = [];

  @override
  List<TodoModel> getTodos() => _todos;

  @override
  void addTodo(TodoModel todo) {
    _todos.add(todo);
  }

  @override
  void updateTodo(String id, bool isDone) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index].isDone = isDone;
    }
  }

  @override
  void deleteTodo(String id) {
    _todos.removeWhere((todo) => todo.id == id);
  }
}
