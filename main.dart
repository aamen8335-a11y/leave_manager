import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'home_screen.dart';
import 'dashboard_screen.dart';
import 'request_form_screen.dart';
import 'settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LeaveManagerApp());
}

class LeaveManagerApp extends StatelessWidget {
  const LeaveManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مدير الإجازات',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        fontFamily: 'Roboto',
      ),
      // أول شاشة تفتح
      home: const LoginScreen(),
      // أو لو عايز تروح للداشبورد مباشرة:
      // home: const DashboardScreen(),

      // مسارات أساسية
      routes: {
        '/home': (context) => const HomeScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/request': (context) => const RequestFormScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
