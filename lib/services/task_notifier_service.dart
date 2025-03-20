import 'dart:async';
import 'package:local_notifier/local_notifier.dart';
import 'package:hive_ce/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskNotifierService {
  static Timer? _timer;

  static void startChecking() async {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      int reminderTime = await _getReminderTime();
      await _checkTasks(reminderTime);
    });
  }

  static Future<int> _getReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('reminderTime') ?? 10; // Par défaut : 10 minutes
  }

  static Future<void> _checkTasks(int reminderTime) async {
    var box = await Hive.openBox<Task>('tasks');
    DateTime now = DateTime.now();

    for (var task in box.values) {
      if (task.status != 'Done') {
        Duration difference = task.dueDate.difference(now);

        if (difference.inMinutes == reminderTime) {
          _sendNotification(task.title);
        }
      }
    }
  }

  static void _sendNotification(String taskTitle) {
    LocalNotification notification = LocalNotification(
      title: 'Task Reminder',
      body: 'Your task "$taskTitle" is due soon!',
    );
    notification.show();
  }
}
