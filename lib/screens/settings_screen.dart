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
            toolbarHeight: 120,
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
          body: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.1,
            ), // 80% de la largeur de l'écran
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDarkModeSwitch(context),
                const SizedBox(height: 20),
                _buildContactUsTile(context),
                const SizedBox(height: 10),
                _buildAboutTile(context),
              ],
            ),
          ),
        );
      },
    );
  }

  // Dark Mode Switch
  Widget _buildDarkModeSwitch(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return GestureDetector(
          onTap: () => appState.toggleDarkMode(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
            ), // Ajuster l'espacement vertical
            child: Row(
              children: [
                Icon(
                  appState.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  size: 26, // Taille de l'icône ajustée
                  color:
                      appState.isDarkMode ? Colors.grey[600] : Colors.grey[600],
                ),
                const SizedBox(
                  width: 16,
                ), // Espacement entre l'icône et le texte
                Text(
                  appState.isDarkMode ? "Dark Mode" : "Light Mode",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 50,
                  height: 30,
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
                        duration: const Duration(milliseconds: 300),
                        left: appState.isDarkMode ? 26 : 4,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
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

  // Contact Us Tile
  Widget _buildContactUsTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.email_outlined, size: 28),
        title: const Text(
          'Report an Issue',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        onTap: () {
          _launchEmail();
        },
      ),
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

  // About Tile
  Widget _buildAboutTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10), // Padding ajusté
      child: ListTile(
        leading: const Icon(Icons.info_outline, size: 28),
        title: const Text(
          'About',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        onTap: () {
          _showAboutDialog(context);
        },
      ),
    );
  }

  // Affiche un dialog "A propos"
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
