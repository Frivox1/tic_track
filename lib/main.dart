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
    appName: 'Tick Track',
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kanban Task Manager',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[100],
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        scaffoldBackgroundColor: Colors.grey[100],
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Raleway',
        dialogTheme: DialogTheme(backgroundColor: Colors.grey[100]),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.black),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.black),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.black,
          ),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: MaterialStateProperty.all(Colors.grey[200]),
          ),
        ),
      ),
      home: MainScreen(),
    );
  }
}
