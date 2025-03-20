import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tic_track/screens/main_screen.dart';
import 'services/hive_service.dart';
import 'package:window_manager/window_manager.dart';
import 'package:provider/provider.dart';
import 'package:local_notifier/local_notifier.dart';
import 'providers/app_state_provider.dart';
import 'providers/selected_index_provider.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/task_notifier_service.dart';
import 'providers/selected_reminder_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  await trayManager.setIcon('assets/images/tic_track_logo.png');

  // Initialisation des notifications locales
  await localNotifier.setup(
    appName: 'Tic Track',
    shortcutPolicy: ShortcutPolicy.requireCreate,
  );

  // Initialisation de la fenêtre principale
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1300, 800),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  await HiveService.initHive();

  TaskNotifierService.startChecking();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => SelectedIndexProvider()),
        ChangeNotifierProvider(create: (_) => SelectedReminderProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();

  static ThemeData lightTheme() {
    return ThemeData(
      fontFamily: 'Raleway',
      brightness: Brightness.light,
      primaryColor: Colors.black,
      scaffoldBackgroundColor: Colors.grey[200],
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 100,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 40,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.grey[50],
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        bodyMedium: TextStyle(color: Colors.black),
        bodySmall: TextStyle(color: Colors.grey),
      ),
      iconTheme: const IconThemeData(color: Colors.grey, size: 22),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      drawerTheme: DrawerThemeData(backgroundColor: Colors.grey[200]),
      listTileTheme: ListTileThemeData(
        iconColor: Colors.black,
        textColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selectedColor: Colors.black87,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.black,
        selectionColor: Colors.red,
        selectionHandleColor: Colors.red,
      ),
      dialogTheme: const DialogTheme(backgroundColor: Colors.white),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      fontFamily: 'Raleway',
      brightness: Brightness.dark,
      primaryColor: Colors.white,
      scaffoldBackgroundColor: const Color(0xFF303030),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 100,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 40,
        ),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF424242),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(color: Colors.grey),
        bodySmall: TextStyle(color: Colors.grey),
      ),
      iconTheme: const IconThemeData(color: Colors.grey, size: 16),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF303030)),
      listTileTheme: ListTileThemeData(
        iconColor: Colors.white70,
        textColor: Colors.white,
        selectedColor: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.white,
        selectionColor: Colors.red,
        selectionHandleColor: Colors.red,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: Color(0xFF424242),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final systemBrightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      Provider.of<AppStateProvider>(
        context,
        listen: false,
      ).setThemeBasedOnSystem(systemBrightness == Brightness.dark);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    final systemBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    Provider.of<AppStateProvider>(
      context,
      listen: false,
    ).setThemeBasedOnSystem(systemBrightness == Brightness.dark);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tic Track',
      theme: MyApp.lightTheme(),
      darkTheme: MyApp.darkTheme(),
      themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Builder(
        builder: (context) {
          // Vérification après le premier rendu
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _checkFirstLaunch(context),
          );
          return MainScreen();
        },
      ),
    );
  }

  Future<void> _checkFirstLaunch(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    bool? firstLaunch = prefs.getBool('firstLaunch');

    if (firstLaunch ?? true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Thank you for installing Tic Track!'),
            content: const Text(
              'Make sure to activate the notifications in the settings to receive reminders and information about the pomodoro timer.',
            ),
            actions: [
              TextButton(
                child: const Text('Sounds good!'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
      await prefs.setBool('firstLaunch', false);
    }
  }
}
