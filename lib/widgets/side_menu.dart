import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SideMenu({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[100],
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(height: 45),
          _buildListTile(0, Icons.view_agenda_outlined, 'Kanban'),
          _buildListTile(1, Icons.label_important_outline_rounded, 'Labels'),
          _buildListTile(2, Icons.calendar_today_outlined, 'Calendar'),
          _buildListTile(3, Icons.timer_outlined, 'Pomodoro'),
        ],
      ),
    );
  }

  Widget _buildListTile(int index, IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: TextStyle(color: Colors.black)),
      selected: selectedIndex == index,
      selectedTileColor: Colors.black.withOpacity(0.1),
      onTap: () => onItemSelected(index),
    );
  }
}
