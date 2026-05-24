// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:to_do_list/views/widgets/add_task_dialog.dart';
import '../screens/notification_test_screen.dart';
import '../view_models/todo_view_model.dart';
import '../widgets/todo_item.dart';
import 'calendar_screen.dart';
import '../models/todo_model.dart';
import '../services/speech_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SpeechService _speechService = SpeechService();
  bool _isListening = false;
  String _currentVoiceText = '';
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _initSpeechAvailability();
  }

  Future<void> _initSpeechAvailability() async {
    final available = await _speechService.initialize();
    if (!mounted) return;
    setState(() => _speechAvailable = available);
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
      return;
    }

    await _speechService.startListening((text) {
      if (!mounted) return;
      setState(() {
        _currentVoiceText = text;
      });
    });

    if (!mounted) return;
    setState(() {
      _isListening = true;
    });
  }

  Future<void> _stopListeningAndAddTodo() async {
    final vm = Provider.of<TodoViewModel>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);

    await _speechService.stopListening();

    if (!mounted) return;
    setState(() {
      _isListening = false;
    });

    final recognized = _speechService.voiceInput.trim();
    if (recognized.isNotEmpty) {
      await vm.addTodo(recognized);
      messenger.showSnackBar(
        SnackBar(content: Text('Added: $recognized')),
      );
      if (!mounted) return;
      setState(() {
        _currentVoiceText = '';
      });
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('No speech recognized')),
      );
    }
  }

  @override
  void dispose() {
    _speechService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TodoViewModel>(context);
    final todos = viewModel.todos;

    // Group by createdAt date.
    final Map<String, List<TodoModel>> grouped = {};
    for (final todo in todos) {
      final key = DateFormat('yyyy-MM-dd').format(todo.createdAt);
      grouped.putIfAbsent(key, () => []).add(todo);
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("My To-Do List"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalendarScreen()),
              );
            },
          ),
          // 🆕 Add notification test button
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NotificationTestScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isListening)
            Container(
              width: double.infinity,
              color: Colors.orange.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                _currentVoiceText.isEmpty ? 'Listening...' : _currentVoiceText,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: sortedKeys.length,
              itemBuilder: (context, index) {
                final key = sortedKeys[index];
                final date = DateTime.parse(key);
                final formatted = DateFormat.yMMMMEEEEd().format(date);
                final items = grouped[key]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Text(
                        formatted,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    ...items.map((todo) {
                      final Color cardColor = todo.isDone
                          ? Colors.blue.shade50
                          : Colors.yellow.shade50;

                      return Dismissible(
                        key: ValueKey(todo.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) async {
                          await viewModel.deleteTodo(todo.id);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${todo.title} deleted"),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        background: Container(
                          color: Colors.red[700],
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete_forever,
                              color: Colors.white),
                        ),
                        child: TodoTitle(
                          todo: todo,
                          cardColor: cardColor,
                          onToggle: (String value) {},
                          onDelete: (String value) {},
                          onUpdateTitle: (String id, String newTitle) {},
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'micFab',
            backgroundColor: Colors.orange,
            child: Icon(_isListening ? Icons.mic_off : Icons.mic),
            onPressed: () async {
              if (!_speechAvailable) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Speech not available')),
                );
                return;
              }
              if (_isListening) {
                await _stopListeningAndAddTodo();
              } else {
                await _startListening();
              }
            },
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'addFab',
            backgroundColor: Colors.teal,
            child: const Icon(Icons.add),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const AddTaskDialog(),
            ),
          ),
        ],
      ),
    );
  }
}
