/* lib/repositories/local_todo_repository.dart
import '../models/todo_model.dart';
import 'todo_repository.dart';

class LocalTodoRepository implements TodoRepository {
// lib/repositories/local_todo_repository.dart

  class LocalTodoRepository implements; TodoRepository {
  final List<TodoModel> _todos = [];

  @override
  List<TodoModel> getTodos() {
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
  // Ensure flag matches dueDate on add
  todo.isdate_set = todo.dueDate != null;
  _todos.add(todo);
  }

  @override
  void updateTodo(String id, bool isDone) {
  final index = _todos.indexWhere((todo) => todo.id == id);
  if (index != -1) {
  _todos[index].isDone = isDone;
  _todos[index].completedAt = isDone ? DateTime.now() : null;
  }
  }

  @override
  void deleteTodo(String id) {
  _todos.removeWhere((todo) => todo.id == id);
  }

  @override
  void updateTodoTitle(String id, String newTitle) {
  final index = _todos.indexWhere((todo) => todo.id == id);
  if (index != -1) {
  _todos[index].title = newTitle;
  }
  }

  @override
  void updateTodoDueDate(String id, DateTime? newDueDate) {
  final index = _todos.indexWhere((todo) => todo.id == id);
  if (index != -1) {
  _todos[index].dueDate = newDueDate;
  _todos[index].isdate_set = newDueDate != null;
  }
  }
  }
}


 */