import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const LeaveManagerApp());
}

class LeaveManagerApp extends StatefulWidget {
  const LeaveManagerApp({super.key});

  @override
  State<LeaveManagerApp> createState() => _LeaveManagerAppState();
}

class _LeaveManagerAppState extends State<LeaveManagerApp> {
  Locale _locale = const Locale('ar');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مدير الإجازات',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      locale: _locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: HomeScreen(
        onToggleLang: () {
          setState(() {
            _locale = _locale.languageCode == 'ar'
                ? const Locale('en')
                : const Locale('ar');
          });
        },
      ),
      routes: {
        '/dashboard': (_) => const DashboardScreen(),
        '/request': (_) => const LeaveRequestScreen(),
        '/login': (_) => const LoginScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  final VoidCallback onToggleLang;
  const HomeScreen({super.key, required this.onToggleLang});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isAr ? 'مدير الإجازات' : 'Leave Manager'),
          actions: [
            IconButton(
              onPressed: onToggleLang,
              tooltip: isAr ? 'تبديل اللغة' : 'Toggle language',
              icon: const Icon(Icons.translate),
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: Text(isAr ? 'تسجيل الدخول' : 'Login'),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () => Navigator.pushNamed(context, '/request'),
                  child: Text(isAr ? 'طلب إجازة' : 'Request Leave'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/dashboard'),
                  child: Text(isAr ? 'لوحة التحكم' : 'Dashboard'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// شاشات بسيطة مؤقتة (Placeholders)
// بدّلها لاحقاً باستيراد ملفاتك الحقيقية: login_screen.dart / dashboard_screen.dart / leave_request.dart
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: Text(isAr ? 'تسجيل الدخول' : 'Login')),
        body: Center(child: Text(isAr ? 'واجهة تسجيل الدخول' : 'Login UI')),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: Text(isAr ? 'لوحة التحكم' : 'Dashboard')),
        body: Center(child: Text(isAr ? 'إحصائيات وطلبات' : 'Stats & Requests')),
      ),
    );
  }
}

class LeaveRequestScreen extends StatelessWidget {
  const LeaveRequestScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: Text(isAr ? 'طلب إجازة' : 'Leave request')),
        body: Center(child: Text(isAr ? 'نموذج طلب الإجازة' : 'Leave request form')),
      ),
    );
  }
}
