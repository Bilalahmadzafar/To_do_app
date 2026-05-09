import 'package:flutter/foundation.dart';
import '../models/todo_model.dart';
import '../repositories/todo_repository.dart';
import 'package:hive/hive.dart';

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
}
