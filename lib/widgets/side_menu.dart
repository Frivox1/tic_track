import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
                      Icons.keyboard_alt_outlined,
                      'Warm-up',
                    ),
                  ],
                ),
              ),
              _buildDarkModeSwitch(context),
              const SizedBox(height: 10),
              _buildContactUsTile(context),
              const SizedBox(height: 10),
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
      leading: Icon(icon, size: 22),
      title: Text(title),
      selected: appState.selectedIndex == index,
      selectedTileColor: Colors.black.withOpacity(0.1),
      onTap: () => appState.setSelectedIndex(index),
    );
  }

  Widget _buildContactUsTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.email_outlined, size: 16),
      title: Text('Report an issue', style: TextStyle(fontSize: 13)),
      onTap: () {
        _launchEmail();
      },
    );
  }

  // Fonction pour lancer une application de messagerie ou un email
  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'mertens.valery@gmail.com',
      queryParameters: {'subject': 'Issue with the app'},
    );

    if (await canLaunch(emailUri.toString())) {
      await launch(emailUri.toString());
    } else {
      throw 'Could not open the email app.';
    }
  }

  Widget _buildDarkModeSwitch(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return GestureDetector(
          onTap: () => appState.toggleDarkMode(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  appState.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  size: 22,
                  color:
                      appState.isDarkMode ? Colors.grey[600] : Colors.grey[600],
                ),
                SizedBox(width: 70),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: 50,
                  height: 25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color:
                        appState.isDarkMode
                            ? Colors.grey[300]
                            : Colors.grey[300],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedPositioned(
                        duration: Duration(milliseconds: 300),
                        left: appState.isDarkMode ? 26 : 4,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
