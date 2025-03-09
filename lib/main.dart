import 'package:flutter/material.dart';
import 'package:tic_track/screens/main_screen.dart';
import 'services/hive_service.dart';
import 'package:window_manager/window_manager.dart';
import 'package:provider/provider.dart';
import 'package:local_notifier/local_notifier.dart';
import 'providers/app_state_provider.dart';
import 'providers/selected_index_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Initialisation des notifications locales
  await localNotifier.setup(
    appName: 'Tic Track',
    shortcutPolicy: ShortcutPolicy.requireCreate,
  );

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
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => SelectedIndexProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static ThemeData lightTheme() {
    return ThemeData(
      fontFamily: 'Raleway',
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.grey[100],
      appBarTheme: AppBarTheme(
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
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        bodyMedium: TextStyle(color: Colors.grey[900]),
        bodySmall: TextStyle(color: Colors.grey),
      ),
      iconTheme: IconThemeData(color: Colors.grey, size: 16),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        disabledColor: Colors.transparent,
        selectedColor: Colors.transparent,
        secondarySelectedColor: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      drawerTheme: DrawerThemeData(backgroundColor: Colors.white),
      listTileTheme: ListTileThemeData(
        iconColor: Colors.black,
        textColor: Colors.black87,
        selectedColor:
            Colors.blue, // Couleur du texte et de l'icône quand sélectionné
        selectedTileColor: Colors.blue.withOpacity(
          0.1,
        ), // Couleur de fond quand sélectionné
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Thème Sombre
  static ThemeData darkTheme() {
    return ThemeData(
      fontFamily: 'Raleway',
      brightness: Brightness.dark,
      primaryColor: Colors.white,
      scaffoldBackgroundColor: Color(0xFF303030),
      appBarTheme: AppBarTheme(
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
        color: Color(0xFF424242),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(color: Colors.grey[300]),
        bodySmall: TextStyle(color: Colors.grey[400]),
      ),
      iconTheme: IconThemeData(color: Colors.grey[400], size: 16),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        disabledColor: Colors.transparent,
        selectedColor: Colors.transparent,
        secondarySelectedColor: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      drawerTheme: DrawerThemeData(backgroundColor: Color(0xFF303030)),
      listTileTheme: ListTileThemeData(
        iconColor: Colors.white70,
        textColor: Colors.white,
        selectedColor: Colors.red,
        selectedTileColor: Colors.tealAccent.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tic Track',
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: ThemeMode.system, // Utilise le mode du système (clair/sombre)
      home: MainScreen(),
    );
  }
}
