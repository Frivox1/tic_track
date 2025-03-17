import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 130,
            title: const Text(
              'Settings',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            iconTheme: Theme.of(context).iconTheme,
            forceMaterialTransparency: true,
            surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  _buildDarkModeSwitch(context),
                  const SizedBox(height: 20),
                  _buildContactUsTile(context),
                  const SizedBox(height: 20),
                  _buildAboutTile(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDarkModeSwitch(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Container(
          width: 500,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    appState.isDarkMode
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    size: 26,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Dark Mode",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Switch(
                value: appState.isDarkMode,
                onChanged: (value) => appState.toggleDarkMode(),
                activeColor: Colors.white,
                activeTrackColor: Colors.grey[600],
                inactiveTrackColor: Colors.grey[400],
              ),
            ],
          ),
        );
      },
    );
  }

  // Contact Us Tile
  Widget _buildContactUsTile(BuildContext context) {
    return Container(
      width: 500,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.email_outlined, size: 28),
        title: const Text(
          'Report an Issue',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        onTap: _launchEmail,
      ),
    );
  }

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

  // About Tile
  Widget _buildAboutTile(BuildContext context) {
    return Container(
      width: 500,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.info_outline, size: 28),
        title: const Text(
          'About',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        onTap: () => _showAboutDialog(context),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('About the App'),
          content: const Text('Version 1.0.0', style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
