import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/views/splash_screen.dart';
import 'models/todo_model.dart';
import 'repositories/hive_todo_repository.dart';
import 'repositories/todo_repository.dart';
import 'view_models/todo_view_model.dart';
import 'views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register the Hive adapter
  Hive.registerAdapter(TodoModelAdapter());

  // Open the box to store todos
  await Hive.openBox<TodoModel>('todos');

  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Use Hive-based repository
        Provider<TodoRepository>(
          create: (_) => HiveTodoRepository(),
        ),
        // ViewModel depends on the repository
        ChangeNotifierProxyProvider<TodoRepository, TodoViewModel>(
          create: (context) => TodoViewModel(context.read<TodoRepository>()),
            update: (context, repo, viewModel) => viewModel!,
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
