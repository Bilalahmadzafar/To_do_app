import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/todo_model.dart';
import '../../../view_models/todo_view_model.dart';
import 'package:hive/hive.dart';


class TodoTitle extends StatelessWidget {
  final TodoModel todo;

  const TodoTitle({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TodoViewModel>(context, listen: false);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      child: ListTile(
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
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => viewModel.deleteTodo(todo.id),
        ),
      ),
    );
  }
}
