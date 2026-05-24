// lib/repositories/todo_repository.dart
import '../models/todo_model.dart';

abstract class TodoRepository {
  /// Get all todos (sorted: unfinished first, newest first inside each group)
  List<TodoModel> getTodos();

  /// Add a new todo
  void addTodo(TodoModel todo);

  /// Update completion state
  void updateTodo(String id, bool isDone);

  /// Update the title of an existing todo
  void updateTodoTitle(String id, String newTitle);

  /// Delete a todo
  void deleteTodo(String id);

  /// Update the due date of an existing todo
  void updateTodoDueDate(String id, DateTime? newDueDate);
}
