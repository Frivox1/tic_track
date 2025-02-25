import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import '../models/task.dart';

class HiveService {
  static const String taskBoxName = 'tasks';

  static Future<void> initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    await Hive.openBox<Task>(taskBoxName);
  }

  static Box<Task> getTaskBox() {
    return Hive.box<Task>(taskBoxName);
  }

  static Future<void> addTask(Task task) async {
    final box = getTaskBox();
    await box.add(task);
  }

  static Future<void> updateTask(Task task) async {
    await task.save();
  }

  static Future<void> deleteTask(Task task) async {
    await task.delete();
  }
}
