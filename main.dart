import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LeaveManagerApp());
}

class LeaveManagerApp extends StatelessWidget {
  const LeaveManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مدير الإجازات',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      home: const LoginScreen(),
      routes: {
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
