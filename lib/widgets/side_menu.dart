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
          backgroundColor: Colors.grey[100],
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
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: TextStyle(color: Colors.black)),
      selected: appState.selectedIndex == index,
      selectedTileColor: Colors.black.withOpacity(0.1),
      onTap: () => appState.setSelectedIndex(index),
    );
  }

  Widget _buildContactUsTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.email_outlined, color: Colors.black),
      title: Text('Get in touch', style: TextStyle(color: Colors.black)),
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
}
