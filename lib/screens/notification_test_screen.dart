// lib/screens/notification_test_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/todo_view_model.dart';
import '../services/notification_service.dart';

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  final NotificationService _notificationService = NotificationService();
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPendingCount();
  }

  Future<void> _loadPendingCount() async {
    final pending = await _notificationService.getPendingNotifications();
    setState(() => _pendingCount = pending.length);
  }

  Future<void> _testImmediateNotification() async {
    final success = await _notificationService.showImmediateNotification(
      title: '✅ Test Notification',
      body: 'Your notifications are working perfectly!',
    );
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success 
          ? 'Notification sent!' 
          : 'Failed to send notification'),
      ),
    );
  }

  Future<void> _testScheduledNotification() async {
    // Schedule a notification 10 seconds from now
    final dueDate = DateTime.now().add(const Duration(seconds: 10));
    final todoId = DateTime.now().millisecondsSinceEpoch.toString();
    
    final success = await _notificationService.scheduleTaskNotification(
      todoId: todoId,
      title: 'Test Task - Should appear in 10 seconds',
      dueDate: dueDate,
    );
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success 
          ? 'Scheduled for 10 seconds from now!' 
          : 'Failed to schedule notification'),
        duration: const Duration(seconds: 3),
      ),
    );
    
    await _loadPendingCount();
  }

  Future<void> _cancelAllNotifications() async {
    await _notificationService.cancelAllNotifications();
    await _loadPendingCount();
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications cancelled')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TodoViewModel>(context, listen: false);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Testing'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notification Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Pending Notifications:'),
                      Chip(
                        label: Text('$_pendingCount'),
                        backgroundColor: Colors.teal.shade100,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _loadPendingCount,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Count'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Test Notifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_active, color: Colors.orange),
                  title: const Text('Immediate Notification'),
                  subtitle: const Text('Show notification right now'),
                  trailing: ElevatedButton(
                    onPressed: _testImmediateNotification,
                    child: const Text('Test'),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.schedule, color: Colors.blue),
                  title: const Text('Scheduled Notification'),
                  subtitle: const Text('Schedule for 10 seconds from now'),
                  trailing: ElevatedButton(
                    onPressed: _testScheduledNotification,
                    child: const Text('Test'),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_sweep, color: Colors.red),
                  title: const Text('Cancel All'),
                  subtitle: const Text('Clear all pending notifications'),
                  trailing: ElevatedButton(
                    onPressed: _cancelAllNotifications,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'ViewModel Integration',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bug_report, color: Colors.purple),
              title: const Text('Test via ViewModel'),
              subtitle: const Text('Test notification through ViewModel'),
              trailing: ElevatedButton(
                onPressed: () async {
                  await viewModel.showTestNotification();
                },
                child: const Text('Test'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
