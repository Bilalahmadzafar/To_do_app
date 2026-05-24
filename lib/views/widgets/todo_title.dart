// lib/views/widgets/todo_title.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/todo_model.dart';
import '../../../view_models/todo_view_model.dart';
import 'add_task_dialog.dart'; // 👈 import dialog for editing

class TodoTitle extends StatelessWidget {
  final TodoModel todo;

  const TodoTitle({super.key, required this.todo});

  void _editTask(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AddTaskDialog(todo: todo),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TodoViewModel>(context, listen: false);

    Widget? subtitle;
    if (todo.isdate_set) {
      if (todo.dueDate != null) {
        subtitle = Text(
          "Due date: ${DateFormat.yMMMd().add_jm().format(todo.dueDate!.toLocal())}",
          style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
        );
      } else {
        subtitle = const Text(
          "Due date: not set",
          style: TextStyle(fontSize: 13, color: Colors.blueGrey),
        );
      }
    } else {
      subtitle = null;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      child: ListTile(
        onTap: () => _editTask(context), // 👈 tap to edit
        leading: Checkbox(
          value: todo.isDone,
          onChanged: (_) => viewModel.toggleTodo(todo.id),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            fontSize: 16,
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
            color: todo.isDone ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: subtitle,
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => viewModel.deleteTodo(todo.id),
        ),
      ),
    );
  }
}
