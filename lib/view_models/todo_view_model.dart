// lib/view_models/todo_view_model.dart
import 'package:flutter/foundation.dart';
import '../models/todo_model.dart';
import '../repositories/todo_repository.dart';
import '../services/notification_service.dart';

class TodoViewModel extends ChangeNotifier {
  final TodoRepository _todoRepository;
  final NotificationService _notificationService = NotificationService();

  TodoViewModel(this._todoRepository);

  List<TodoModel> get todos => _todoRepository.getTodos();

  /// Add todo with optional due date. Returns the created todo id.
  Future<String> addTodo(String title, {DateTime? dueDate}) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final todo = TodoModel(
      id: id,
      title: title,
      dueDate: dueDate,
      isdate_set: dueDate != null,
    );

    _todoRepository.addTodo(todo);
    
    // 🆕 Schedule notification if due date is set
    if (dueDate != null && dueDate.isAfter(DateTime.now())) {
      await _notificationService.scheduleTaskNotification(
        todoId: id,
        title: title,
        dueDate: dueDate,
      );
    }
    
    notifyListeners();
    return id;
  }

  /// Toggle completion state
  Future<void> toggleTodo(String id) async {
    final todo = todos.firstWhere((todo) => todo.id == id);
    final newState = !todo.isDone;
    
    _todoRepository.updateTodo(id, newState);
    
    // 🆕 Cancel notification when task is marked as done
    if (newState == true) {
      await _notificationService.cancelTaskNotification(id);
    } else {
      // 🆕 Re-schedule notification if task is unmarked and has future due date
      if (todo.dueDate != null && todo.dueDate!.isAfter(DateTime.now())) {
        await _notificationService.scheduleTaskNotification(
          todoId: id,
          title: todo.title,
          dueDate: todo.dueDate!,
        );
      }
    }
    
    notifyListeners();
  }

  /// Delete todo
  Future<void> deleteTodo(String id) async {
    // 🆕 Cancel notification before deleting
    await _notificationService.cancelTaskNotification(id);
    
    _todoRepository.deleteTodo(id);
    notifyListeners();
  }

  /// Update the title of an existing todo
  Future<void> updateTodoTitle(String id, String newTitle) async {
    if (newTitle.trim().isEmpty) return;
    
    _todoRepository.updateTodoTitle(id, newTitle.trim());
    
    // 🆕 Update notification if task has a future due date
    final todo = todos.firstWhere((t) => t.id == id);
    if (todo.dueDate != null && 
        todo.dueDate!.isAfter(DateTime.now()) && 
        !todo.isDone) {
      await _notificationService.cancelTaskNotification(id);
      await _notificationService.scheduleTaskNotification(
        todoId: id,
        title: newTitle.trim(),
        dueDate: todo.dueDate!,
      );
    }
    
    notifyListeners();
  }

  /// Update the due date of an existing todo
  Future<void> updateTodoDueDate(String id, DateTime? newDueDate) async {
    _todoRepository.updateTodoDueDate(id, newDueDate);
    
    // 🆕 Always cancel existing notification first
    await _notificationService.cancelTaskNotification(id);
    
    // 🆕 Schedule new notification if due date is set and in the future
    if (newDueDate != null && newDueDate.isAfter(DateTime.now())) {
      final todo = todos.firstWhere((t) => t.id == id);
      if (!todo.isDone) {
        await _notificationService.scheduleTaskNotification(
          todoId: id,
          title: todo.title,
          dueDate: newDueDate,
        );
      }
    }
    
    notifyListeners();
  }

  /// 🆕 Debug: Get pending notifications count
  Future<int> getPendingNotificationsCount() async {
    final pending = await _notificationService.getPendingNotifications();
    return pending.length;
  }

  /// 🆕 Debug: Show test notification
  Future<void> showTestNotification() async {
    await _notificationService.showImmediateNotification(
      title: 'Test Notification',
      body: 'Your notification system is working! 🎉',
    );
  }
}
