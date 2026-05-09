import '../models/todo_model.dart';

abstract class TodoRepository {
  List<TodoModel> getTodos();
  void addTodo(TodoModel todo);
  void updateTodo(String id, bool isDone);
  void deleteTodo(String id);
}
