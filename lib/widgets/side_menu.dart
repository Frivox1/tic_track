import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Drawer(
          backgroundColor: Colors.grey[100],
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(height: 45),
              _buildListTile(context, 0, Icons.view_agenda_outlined, 'Kanban'),
              _buildListTile(context, 1, Icons.category_outlined, 'Categories'),
              _buildListTile(
                context,
                2,
                Icons.label_important_outline_rounded,
                'Labels',
              ),
              _buildListTile(
                context,
                3,
                Icons.calendar_today_outlined,
                'Calendar',
              ),
              _buildListTile(context, 4, Icons.timer_outlined, 'Pomodoro'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListTile(
    BuildContext context,
    int index,
    IconData icon,
    String title,
  ) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: TextStyle(color: Colors.black)),
      selected: appState.selectedIndex == index,
      selectedTileColor: Colors.black.withOpacity(0.1),
      onTap: () => appState.setSelectedIndex(index),
    );
  }
}
