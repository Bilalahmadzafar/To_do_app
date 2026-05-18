// lib/widgets/todo_title.dart
import 'package:flutter/material.dart';
import '../models/todo_model.dart';

/// TodoTitle widget with tap-to-edit dialog and configurable card color.
class TodoTitle extends StatelessWidget {
  final TodoModel todo;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onDelete;
  final void Function(String id, String newTitle) onUpdateTitle;

  /// Optional: override the card background color. If null, theme's cardColor is used.
  final Color? cardColor;

  const TodoTitle({
    Key? key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.onUpdateTitle,
    this.cardColor,
  }) : super(key: key);

  Future<void> _showEditDialog(BuildContext context) async {
    final controller = TextEditingController(text: todo.title);

    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter new title',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                Navigator.of(context).pop(text.isEmpty ? null : text);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (newTitle != null && newTitle.isNotEmpty && newTitle != todo.title) {
      onUpdateTitle(todo.id, newTitle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: 16,
      decoration:
          todo.isDone ? TextDecoration.lineThrough : TextDecoration.none,
      color: todo.isDone ? Colors.grey : Colors.black,
    );

    // Resolve the effective color: explicit cardColor -> dynamic based on todo -> theme fallback
    final Color effectiveCardColor = cardColor ??
        (todo.isDone ? Colors.grey.shade100 : Theme.of(context).cardColor);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Card(
        color: effectiveCardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors
              .transparent, // keep Card color visible while enabling ink effects
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            leading: Checkbox(
              value: todo.isDone,
              onChanged: (_) => onToggle(todo.id),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
            title: Text(
              todo.title,
              style: titleStyle,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDelete(todo.id),
              tooltip: 'Delete',
            ),
            onTap: () => _showEditDialog(context),
          ),
        ),
      ),
    );
  }
}
