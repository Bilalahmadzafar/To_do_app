// lib/repositories/todo_repository.dart
import '../models/todo_model.dart';

abstract class TodoRepository {
  List<TodoModel> getTodos();
  void addTodo(TodoModel todo);
  void updateTodo(String id, bool isDone);
  void updateTodoTitle(String id, String newTitle);
  void deleteTodo(String id);
}
