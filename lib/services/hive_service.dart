import 'package:hive_ce_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../models/label.dart';
import '../models/category.dart';

class HiveService {
  static const String taskBoxName = 'tasks';
  static const String labelBoxName = 'labels';
  static const String categoryBoxName = 'categories';

  static Future<void> initHive() async {
    await Hive.initFlutter();

    // Vérifie si les adaptateurs sont déjà enregistrés pour éviter les erreurs
    if (!Hive.isAdapterRegistered(TaskAdapter().typeId)) {
      Hive.registerAdapter(TaskAdapter());
    }
    if (!Hive.isAdapterRegistered(LabelAdapter().typeId)) {
      Hive.registerAdapter(LabelAdapter());
    }
    if (!Hive.isAdapterRegistered(CategoryAdapter().typeId)) {
      Hive.registerAdapter(CategoryAdapter());
    }

    // Réouvre les Box après suppression
    await Future.wait([
      Hive.openBox<Category>(categoryBoxName),
      Hive.openBox<Task>(taskBoxName),
      Hive.openBox<Label>(labelBoxName),
    ]);
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

  static Box<Category> getCategoryBox() {
    return Hive.box<Category>('categories');
  }

  static void addCategory(Category category) {
    getCategoryBox().add(category);
  }

  static void updateCategory(Category category) {
    category.save();
  }

  static void deleteCategory(Category category) {
    category.delete();
  }

  static Category? getCategory(int categoryId) {
    final box = Hive.box<Category>('categories');
    return box.get(categoryId);
  }
}
