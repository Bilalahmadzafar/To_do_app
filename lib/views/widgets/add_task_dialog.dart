// lib/views/widgets/add_task_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/todo_model.dart';
import '../../../view_models/todo_view_model.dart';

class AddTaskDialog extends StatefulWidget {
  final TodoModel? todo; // optional todo for editing

  const AddTaskDialog({super.key, this.todo});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _dueDateEnabled = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      _controller.text = widget.todo!.title;
      // Use the boolean flag if present; fallback to dueDate check
      _dueDateEnabled = widget.todo!.isdate_set || widget.todo!.dueDate != null;
      if (widget.todo!.dueDate != null) {
        _selectedDate = widget.todo!.dueDate;
        _selectedTime = TimeOfDay.fromDateTime(widget.todo!.dueDate!);
      } else if (_dueDateEnabled) {
        // Flag says due date is set but dueDate is null — initialize to near-future
        final now = DateTime.now().add(const Duration(minutes: 1));
        _selectedDate = DateTime(now.year, now.month, now.day);
        _selectedTime = TimeOfDay(hour: now.hour, minute: now.minute);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  DateTime? get _combinedDateTime {
    if (!_dueDateEnabled) return null;
    final date = _selectedDate;
    final time = _selectedTime;
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String get _dueDateSummary {
    final dt = _combinedDateTime;
    if (dt == null) return 'No due date';
    return DateFormat.yMMMd().add_jm().format(dt.toLocal());
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _selectedDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final initial = _selectedTime ?? TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _clearDueDate() {
    setState(() {
      _dueDateEnabled = false;
      _selectedDate = null;
      _selectedTime = null;
    });
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    final dueAt = _combinedDateTime;
    if (_dueDateEnabled && dueAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick date and time for the due date')),
      );
      return;
    }

    if (dueAt != null && dueAt.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected due date is in the past')),
      );
      return;
    }

    final viewModel = Provider.of<TodoViewModel>(context, listen: false);

    if (widget.todo == null) {
      // Adding new task
      viewModel.addTodo(text, dueDate: dueAt);
    } else {
      // Editing existing task: update title and due date flag
      viewModel.updateTodoTitle(widget.todo!.id, text);
      viewModel.updateTodoDueDate(widget.todo!.id, dueAt);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isAddEnabled = _controller.text.trim().isNotEmpty;
    return AlertDialog(
      title: Text(widget.todo == null ? 'Add Task' : 'Edit Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                hintText: 'Enter task title',
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Set due date'),
              subtitle: Text(_dueDateSummary),
              value: _dueDateEnabled,
              onChanged: (v) => setState(() {
                _dueDateEnabled = v;
                if (!v) {
                  _selectedDate = null;
                  _selectedTime = null;
                } else {
                  final now = DateTime.now().add(const Duration(minutes: 1));
                  _selectedDate ??= DateTime(now.year, now.month, now.day);
                  _selectedTime ??= TimeOfDay(hour: now.hour, minute: now.minute);
                }
              }),
            ),
            if (_dueDateEnabled) ...[
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Date'),
                      subtitle: Text(
                        _selectedDate == null
                            ? 'Not selected'
                            : DateFormat.yMMMd().format(_selectedDate!),
                      ),
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Time'),
                      subtitle: Text(
                        _selectedTime == null
                            ? 'Not selected'
                            : _selectedTime!.format(context),
                      ),
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _clearDueDate,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear due date'),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isAddEnabled ? _submit : null,
          child: Text(widget.todo == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
