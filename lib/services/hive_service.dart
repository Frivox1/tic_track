import 'package:hive_ce_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../models/label.dart';
import '../models/category.dart';
import '../models/note.dart';

class HiveService {
  static const String taskBoxName = 'tasks';
  static const String labelBoxName = 'labels';
  static const String categoryBoxName = 'categories';
  static const String noteBoxName = 'notes';

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
    if (!Hive.isAdapterRegistered(NoteAdapter().typeId)) {
      Hive.registerAdapter(NoteAdapter());
    }

    await Future.wait([
      Hive.openBox<Category>(categoryBoxName),
      Hive.openBox<Task>(taskBoxName),
      Hive.openBox<Label>(labelBoxName),
      Hive.openBox<Note>(noteBoxName),
    ]);
  }

  // Gestion des tâches
  static Box<Task> getTaskBox() => Hive.box<Task>(taskBoxName);

  static Future<void> addTask(Task task) async => await getTaskBox().add(task);

  static Future<void> updateTask(Task task) async => await task.save();

  static Future<void> deleteTask(Task task) async => await task.delete();

  // Gestion des labels
  static Box<Label> getLabelBox() => Hive.box<Label>(labelBoxName);

  static Future<void> addLabel(Label label) async =>
      await getLabelBox().add(label);

  static Future<void> updateLabel(Label label) async => await label.save();

  static Future<void> deleteLabel(Label label) async => await label.delete();

  static Label? getLabelByName(String name) {
    try {
      return getLabelBox().values.firstWhere((label) => label.name == name);
    } catch (e) {
      return null;
    }
  }

  // Gestion des catégories
  static Box<Category> getCategoryBox() => Hive.box<Category>(categoryBoxName);

  static Future<void> addCategory(Category category) async =>
      await getCategoryBox().add(category);

  static Future<void> updateCategory(Category category) async =>
      await category.save();

  static Future<void> deleteCategory(Category category) async =>
      await category.delete();

  static Category? getCategory(int categoryId) =>
      getCategoryBox().get(categoryId);

  // Gestion des notes
  static Box<Note> getNoteBox() => Hive.box<Note>(noteBoxName);

  static Future<void> addNote(Note note) async => await getNoteBox().add(note);

  static Future<void> updateNote(Note note) async => await note.save();

  static Future<void> deleteNote(Note note) async => await note.delete();
}
