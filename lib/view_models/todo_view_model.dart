// lib/view_models/todo_view_model.dart
import 'package:flutter/foundation.dart';
import '../models/todo_model.dart';
import '../repositories/todo_repository.dart';

class TodoViewModel extends ChangeNotifier {
  final TodoRepository _todoRepository;

  TodoViewModel(this._todoRepository);

  List<TodoModel> get todos => _todoRepository.getTodos();

  void addTodo(String title) {
    final todo = TodoModel(id: DateTime.now().toString(), title: title);
    _todoRepository.addTodo(todo);
    notifyListeners();
  }

  void toggleTodo(String id) {
    final todo = todos.firstWhere((todo) => todo.id == id);
    _todoRepository.updateTodo(id, !todo.isDone);
    notifyListeners();
  }

  void deleteTodo(String id) {
    _todoRepository.deleteTodo(id);
    notifyListeners();
  }

  /// Update the title of an existing todo
  void updateTodoTitle(String id, String newTitle) {
    if (newTitle.trim().isEmpty) return;
    _todoRepository.updateTodoTitle(id, newTitle.trim());
    notifyListeners();
  }
}
