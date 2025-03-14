import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tic_track/screens/calendar_screen.dart';
import 'package:tic_track/screens/settings_screen.dart';
import 'category_screen.dart';
import 'home_screen.dart';
import 'label_screen.dart';
import '../widgets/side_menu.dart';
import 'pomodoro_screen.dart';
import '../providers/app_state_provider.dart';
import 'still_dev_screen.dart';
import 'notes_screen.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final List<Widget> _screens = [
    HomeScreen(),
    CategoryScreen(),
    LabelScreen(),
    CalendarScreen(),
    PomodoroScreen(),
    NotesScreen(),
    StillDevScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Scaffold(
          body: Row(
            children: [
              SizedBox(width: 180, child: SideMenu()),
              const VerticalDivider(
                thickness: 0.5,
                width: 1,
                color: Colors.grey,
              ),
              Expanded(
                child: IndexedStack(
                  index: appState.selectedIndex,
                  children: _screens,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
