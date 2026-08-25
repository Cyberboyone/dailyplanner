import 'package:flutter/material.dart';
import 'screens/day_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const DailyPlannerApp());
}

class DailyPlannerApp extends StatelessWidget {
  const DailyPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final seed = const Color(0xFF3D5AFE);

    return MaterialApp(
      title: 'Daily Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const DayScreen(),
    );
  }
}
