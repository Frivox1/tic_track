import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectedReminderProvider extends ChangeNotifier {
  int _reminderTime = 10; // Valeur par défaut (10 minutes)

  int get reminderTime => _reminderTime;

  SelectedReminderProvider() {
    _loadReminderTime();
  }

  Future<void> _loadReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    _reminderTime = prefs.getInt('reminderTime') ?? 10;
    notifyListeners();
  }

  Future<void> setReminderTime(int newTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminderTime', newTime);
    _reminderTime = newTime;
    notifyListeners();
  }
}
