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
import 'package:hotkey_manager/hotkey_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await hotKeyManager.unregisterAll();

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

  // Initialisation du gestionnaire de raccourcis clavier
  await hotKeyManager.register(
    HotKey(key: LogicalKeyboardKey.keyP, modifiers: [HotKeyModifier.control]),
    keyDownHandler: (_) async {
      await _showSmallWindow();
    },
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => SelectedIndexProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _showSmallWindow() async {
  // Modifier la taille et l'apparence de la fenêtre principale pour simuler une petite fenêtre flottante
  await windowManager.setBounds(
    Rect.fromLTWH(0, 0, 400, 300),
  ); // Position et taille de la petite fenêtre
  await windowManager.setAlwaysOnTop(
    true,
  ); // Assurer que la fenêtre soit toujours au-dessus des autres
  await windowManager
      .show(); // Afficher la fenêtre si elle n'est pas déjà affichée
  await windowManager.focus(); // Mettre la fenêtre au premier plan
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

    // Attendre la fin du premier build avant de changer l'état
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
      home: MainScreen(),
    );
  }
}
