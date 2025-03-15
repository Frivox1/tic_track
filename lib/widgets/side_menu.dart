import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../screens/settings_screen.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Drawer(
          child: Column(
            children: [
              // Liste des items du menu
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    SizedBox(height: 45),
                    _buildListTile(
                      context,
                      0,
                      Icons.view_column_outlined,
                      'Kanban',
                    ),
                    _buildListTile(
                      context,
                      1,
                      Icons.folder_open_outlined,
                      'Categories',
                    ),
                    _buildListTile(
                      context,
                      2,
                      Icons.local_offer_outlined,
                      'Labels',
                    ),
                    _buildListTile(
                      context,
                      3,
                      Icons.calendar_today_outlined,
                      'Calendar',
                    ),
                    _buildListTile(
                      context,
                      4,
                      Icons.timer_outlined,
                      'Pomodoro',
                    ),
                    _buildListTile(
                      context,
                      5,
                      Icons.sticky_note_2_outlined,
                      'Notes',
                    ),
                    _buildListTile(
                      context,
                      6,
                      Icons.keyboard_alt_outlined,
                      'Warm-up',
                    ),
                  ],
                ),
              ),
              _buildSettingsTile(context),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  // Fonction pour construire un ListTile pour chaque item du menu
  Widget _buildListTile(
    BuildContext context,
    int index,
    IconData icon,
    String title,
  ) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(title),
      selected: appState.selectedIndex == index,
      selectedTileColor: Colors.black.withOpacity(0.1),
      onTap: () => appState.setSelectedIndex(index),
    );
  }

  // Nouveau bouton pour accéder à la page Settings
  Widget _buildSettingsTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.settings_outlined, size: 22),
      title: Text('Settings'),
      onTap: () {
        // Naviguer vers la page Settings
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsScreen()),
        );
      },
    );
  }
}
