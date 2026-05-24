// lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Configure local timezone for accurate scheduling
  Future<void> configureLocalTimeZone() async {
    try {
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('✅ Timezone configured: $timeZoneName');
    } catch (e) {
      debugPrint('❌ Error configuring timezone: $e');
    }
  }

  /// Initialize notifications (call this in main.dart)
  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      // Configure timezone first
      await configureLocalTimeZone();

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      const initSettings = InitializationSettings(
        android: androidSettings,
      );

      final initialized = await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized == true) {
        _initialized = true;
        debugPrint('✅ Notifications initialized successfully');

        // Request permissions for Android 13+
        await _requestPermissions();

        return true;
      } else {
        debugPrint('❌ Notification initialization failed');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
      return false;
    }
  }

  /// Request notification permissions (Android 13+)
  Future<bool> _requestPermissions() async {
    try {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        debugPrint('📱 Notification permission: ${granted == true ? "Granted" : "Denied"}');
        return granted ?? false;
      }
      return true;
    } catch (e) {
      debugPrint('❌ Error requesting permissions: $e');
      return false;
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
    // You can add navigation logic here if needed
  }

  /// Generate a stable notification ID from todo ID
  int _generateNotificationId(String todoId) {
    // Use hash code to generate a stable integer ID
    return todoId.hashCode.abs() % 2147483647; // Max int32 value
  }

  /// Schedule a notification for a task
  Future<bool> scheduleTaskNotification({
    required String todoId,
    required String title,
    required DateTime dueDate,
  }) async {
    if (!_initialized) {
      debugPrint('⚠️ Notifications not initialized');
      return false;
    }

    // Don't schedule notifications for past dates
    if (dueDate.isBefore(DateTime.now())) {
      debugPrint('⚠️ Cannot schedule notification for past date');
      return false;
    }

    try {
      final notificationId = _generateNotificationId(todoId);
      final scheduledDate = tz.TZDateTime.from(dueDate, tz.local);

      await _notificationsPlugin.zonedSchedule(
        notificationId,
        '📋 Task Reminder',
        title,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'todo_channel',
            'To-Do Reminders',
            channelDescription: 'Notifications for scheduled to-do tasks',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      /*  uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,*/
        payload: todoId,
      );

      debugPrint('✅ Notification scheduled for "$title" at ${dueDate.toString()}');
      return true;
    } catch (e) {
      debugPrint('❌ Error scheduling notification: $e');
      return false;
    }
  }

  /// Cancel a scheduled notification
  Future<bool> cancelTaskNotification(String todoId) async {
    if (!_initialized) return false;

    try {
      final notificationId = _generateNotificationId(todoId);
      await _notificationsPlugin.cancel(notificationId);
      debugPrint('🗑️ Notification cancelled for todo: $todoId');
      return true;
    } catch (e) {
      debugPrint('❌ Error cancelling notification: $e');
      return false;
    }
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    if (!_initialized) return;

    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('🗑️ All notifications cancelled');
    } catch (e) {
      debugPrint('❌ Error cancelling all notifications: $e');
    }
  }

  /// Get list of pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_initialized) return [];

    try {
      final pending = await _notificationsPlugin.pendingNotificationRequests();
      debugPrint('📋 Pending notifications: ${pending.length}');
      return pending;
    } catch (e) {
      debugPrint('❌ Error getting pending notifications: $e');
      return [];
    }
  }

  /// Show immediate notification (for testing)
  Future<bool> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    if (!_initialized) return false;

    try {
      await _notificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch % 100000,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'todo_channel',
            'To-Do Reminders',
            channelDescription: 'Notifications for to-do tasks',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
      debugPrint('✅ Immediate notification shown');
      return true;
    } catch (e) {
      debugPrint('❌ Error showing notification: $e');
      return false;
    }
  }
}
