import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/background_tasks.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await registerMorningTask();
  runApp(const DailyFactsApp());
}

class DailyFactsApp extends StatelessWidget {
  const DailyFactsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Факт дня',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const HomeScreen(),
    );
  }
}
