// lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/todo_model.dart';
import 'repositories/hive_todo_repository.dart';
import 'repositories/todo_repository.dart';
import 'view_models/todo_view_model.dart';
import 'views/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and register adapters
  await Hive.initFlutter();
  Hive.registerAdapter(TodoModelAdapter());

  // Open the todos box (log errors but allow app to start in debug)
  try {
    await Hive.openBox<TodoModel>('todos');
  } catch (e, st) {
    debugPrint('Failed to open Hive box "todos": $e\n$st');
  }

  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide the repository as a singleton for the app lifetime.
        Provider<TodoRepository>(
          create: (_) => HiveTodoRepository(),
          // Do not call dispose here unless the repository exposes a cleanup method.
          // If HiveTodoRepository implements a close/dispose method, use the line below:
          // dispose: (_, repo) => repo.close(), // <-- only if `close()` exists
        ),

        // Provide the ViewModel that depends on the repository.
        ChangeNotifierProvider<TodoViewModel>(
          create: (context) {
            final repo = context.read<TodoRepository>();
            final vm = TodoViewModel(repo);
            // If your ViewModel needs to load data on creation, call it here:
            // vm.loadTodos();
            return vm;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Beautiful To-Do App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
