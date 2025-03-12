import 'package:flutter/foundation.dart';
import '../services/hive_service.dart';
import '../models/category.dart' as AppCategory;
import '../models/label.dart';
import '../models/task.dart';

class AppStateProvider with ChangeNotifier {
  int _selectedIndex = 0;
  bool _isDarkMode = false;

  int get selectedIndex => _selectedIndex;
  bool get isDarkMode => _isDarkMode;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  List<AppCategory.Category> get categories =>
      HiveService.getCategoryBox().values.toList();
  List<Label> get labels => HiveService.getLabelBox().values.toList();
  List<Task> get tasks => HiveService.getTaskBox().values.toList();

  void refreshData() {
    notifyListeners();
  }

  // Méthodes pour gérer les catégories
  Future<void> addCategory(AppCategory.Category category) async {
    HiveService.addCategory(category);
    refreshData();
  }

  Future<void> updateCategory(AppCategory.Category category) async {
    HiveService.updateCategory(category);
    refreshData();
  }

  Future<void> deleteCategory(AppCategory.Category category) async {
    HiveService.deleteCategory(category);
    refreshData();
  }

  // Méthodes pour gérer les labels
  Future<void> addLabel(Label label) async {
    await HiveService.addLabel(label);
    refreshData();
  }

  Future<void> updateLabel(Label label) async {
    await HiveService.updateLabel(label);
    refreshData();
  }

  Future<void> deleteLabel(Label label) async {
    await HiveService.deleteLabel(label);
    refreshData();
  }

  // Méthodes pour gérer les tâches
  Future<void> addTask(Task task) async {
    await HiveService.addTask(task);
    refreshData();
  }

  Future<void> updateTask(Task task, {Label? newLabel}) async {
    if (newLabel != null) {
      task.label = newLabel.name;
      task.save();
    }

    await HiveService.updateTask(task);
    refreshData();
  }

  Future<void> deleteTask(Task task) async {
    await HiveService.deleteTask(task);
    refreshData();
  }

  // Méthodes utilitaires
  AppCategory.Category? getCategoryById(int id) {
    try {
      return categories.firstWhere((category) => category.key == id);
    } catch (e) {
      return null;
    }
  }

  // Ajout de la méthode demandée
  AppCategory.Category? getCategory(int id) {
    return getCategoryById(id);
  }

  Label? getLabelByName(String name) {
    try {
      return labels.firstWhere((label) => label.name == name);
    } catch (e) {
      return null;
    }
  }

  List<Task> getTasksByStatus(String status) {
    return tasks.where((task) => task.status == status).toList();
  }
}
