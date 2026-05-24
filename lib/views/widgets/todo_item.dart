// lib/views/widgets/todo_item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/todo_model.dart';
import '../../../view_models/todo_view_model.dart';
import 'add_task_dialog.dart';

class TodoTitle extends StatelessWidget {
  final TodoModel todo;
  final Color cardColor;

  const TodoTitle({
    super.key,
    required this.todo,
    this.cardColor = Colors.white,
  });

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
        final isOverdue = todo.dueDate!.isBefore(DateTime.now()) && !todo.isDone;
        subtitle = Row(
          children: [
            Icon(
              Icons.schedule,
              size: 14,
              color: isOverdue ? Colors.red : Colors.blueGrey,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                "Due: ${DateFormat.yMMMd().add_jm().format(todo.dueDate!.toLocal())}",
                style: TextStyle(
                  fontSize: 13,
                  color: isOverdue ? Colors.red : Colors.blueGrey,
                  fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isOverdue)
              const Text(
                'OVERDUE',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        );
      } else {
        subtitle = const Text(
          "Due date: not set",
          style: TextStyle(fontSize: 13, color: Colors.blueGrey),
        );
      }
    }

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ListTile(
        onTap: () => _editTask(context),
        leading: Checkbox(
          value: todo.isDone,
          onChanged: (_) async => await viewModel.toggleTodo(todo.id),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            fontSize: 16,
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
            color: todo.isDone ? Colors.grey : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle,
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () async => await viewModel.deleteTodo(todo.id),
        ),
      ),
    );
  }
}
