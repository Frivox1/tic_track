import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../models/label.dart';

class HiveService {
  static const String taskBoxName = 'tasks';
  static const String labelBoxName = 'labels';

  static Future<void> initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(LabelAdapter());
    await Hive.openBox<Task>(taskBoxName);
    await Hive.openBox<Label>(labelBoxName);
  }

  static Box<Task> getTaskBox() {
    return Hive.box<Task>(taskBoxName);
  }

  static Box<Label> getLabelBox() {
    return Hive.box<Label>(labelBoxName);
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

  static Future<void> addLabel(Label label) async {
    final box = getLabelBox();
    await box.add(label);
  }

  static Future<void> updateLabel(Label label) async {
    await label.save();
  }

  static Future<void> deleteLabel(Label label) async {
    await label.delete();
  }

  static Label? getLabelByName(String name) {
    final labelBox = getLabelBox();
    try {
      return labelBox.values.firstWhere((label) => label.name == name);
    } catch (e) {
      return null;
    }
  }
}
