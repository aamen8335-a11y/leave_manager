import 'package:flutter/material.dart';
import 'dart:ui' as ui;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LeaveManagerApp());
}

class LeaveManagerApp extends StatefulWidget {
  const LeaveManagerApp({Key? key}) : super(key: key);
  @override
  State<LeaveManagerApp> createState() => _LeaveManagerAppState();
}

class _LeaveManagerAppState extends State<LeaveManagerApp> {
  Locale _locale = const Locale('ar'); // افتراضي عربي
  void _toggleLocale() {
    setState(() {
      _locale = _locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = _locale.languageCode == 'ar';
    final txtDir = isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr;

    return Directionality(
      textDirection: txtDir,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: _locale,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
          useMaterial3: true,
        ),
        home: HomeScreen(onToggleLocale: _toggleLocale, isArabic: isArabic),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final VoidCallback onToggleLocale;
  final bool isArabic;
  const HomeScreen({super.key, required this.onToggleLocale, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'مدير الإجازات' : 'Leave Manager'),
        actions: [
          IconButton(icon: const Icon(Icons.language),
            tooltip: isArabic ? 'تبديل اللغة' : 'Switch language',
            onPressed: onToggleLocale),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tile(context, isArabic ? 'تسجيل الدخول' : 'Login',
              isArabic ? 'ادخل بحسابك' : 'Sign in', Icons.login, const LoginScreen()),
          _gap(),
          _tile(context, isArabic ? 'طلب إجازة' : 'Request Leave',
              isArabic ? 'أرسل طلبًا جديدًا' : 'Send new request',
              Icons.event_available, const RequestScreen()),
          _gap(),
          _tile(context, isArabic ? 'لوحة القيادة' : 'Dashboard',
              isArabic ? 'مراجعة الطلبات' : 'Review requests',
              Icons.dashboard, const DashboardScreen()),
          _gap(),
          _tile(context, isArabic ? 'التقارير (CSV)' : 'Reports (CSV)',
              isArabic ? 'تصدير تقرير شهري' : 'Export monthly CSV',
              Icons.file_download, const ReportScreen()),
        ],
      ),
    );
  }

  SizedBox _gap() => const SizedBox(height: 12);

  Card _tile(BuildContext c, String title, String sub, IconData ic, Widget page) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(sub),
        trailing: Icon(ic),
        onTap: () => Navigator.of(c).push(MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }
}

/// شاشات مبدئية — تقدر تبدّلها لاحقًا
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) => _scaffold(context, 'تسجيل الدخول / Login', 'نموذج تسجيل الدخول');
}

class RequestScreen extends StatelessWidget {
  const RequestScreen({super.key});
  @override
  Widget build(BuildContext context) => _scaffold(context, 'طلب إجازة / Leave Request', 'نموذج طلب الإجازة');
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => _scaffold(context, 'لوحة القيادة / Dashboard', 'قائمة الطلبات للموافقة');
}

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});
  @override
  Widget build(BuildContext context) => _scaffold(context, 'التقارير / Reports', 'تصدير CSV الشهري');
}

Widget _scaffold(BuildContext c, String title, String body) {
  return Scaffold(appBar: AppBar(title: Text(title)), body: Center(child: Text(body)));
}
