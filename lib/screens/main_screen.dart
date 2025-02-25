import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'label_screen.dart';
import '../widgets/side_menu.dart';
import 'pomodoro_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const LabelScreen(),
    const Placeholder(),
    const PomodoroScreen(),
  ];

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 180,
            child: SideMenu(
              selectedIndex: _selectedIndex,
              onItemSelected: _onItemSelected,
            ),
          ),
          const VerticalDivider(thickness: 0.5, width: 1, color: Colors.grey),
          Expanded(
            child: IndexedStack(index: _selectedIndex, children: _screens),
          ),
        ],
      ),
    );
  }
}
