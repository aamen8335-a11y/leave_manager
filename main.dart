import 'package:flutter/material.dart';
// Firebase مبدئيًا إيقاف التهيئة حتى تُضيف google-services.json لاحقًا
// import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // حاول تُفعّل السطرين دول بعد إضافة Firebase:
  // await Firebase.initializeApp();
  runApp(const LeaveApp());
}

class LeaveApp extends StatelessWidget {
  const LeaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'sans',
      ),
      locale: const Locale('ar'),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final pages = const [RequestsPage(), ApprovalsPage(), DashboardPage(), SettingsPage()];
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('مدير الإجازات')),
        body: pages[_index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i)=>setState(()=>_index=i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.post_add_outlined), label: 'طلب إجازة'),
            NavigationDestination(icon: Icon(Icons.verified_outlined), label: 'الموافقات'),
            NavigationDestination(icon: Icon(Icons.pie_chart_outline), label: 'لوحة التحكم'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'الإعدادات'),
          ],
        ),
        floatingActionButton: _index==0? FloatingActionButton.extended(
          onPressed: (){},
          icon: const Icon(Icons.add),
          label: const Text('طلب جديد'),
        ):null,
      ),
    );
  }
}

class RequestsPage extends StatelessWidget{
  const RequestsPage({super.key});
  @override
  Widget build(BuildContext context){
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('أنواع الإجازة', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: const [
            Chip(label: Text('سنوية')), Chip(label: Text('مرضية')), Chip(label: Text('بدون راتب')), Chip(label: Text('أخرى'))
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(onPressed: (){}, icon: const Icon(Icons.upload_file), label: const Text('تصدير تقرير CSV')),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            title: const Text('مثال: طلب إجازة سنوية'),
            subtitle: const Text('من 2025-10-21 إلى 2025-10-25 • 5 أيام'),
            trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: (){}),
          ),
        ),
      ],
    );
  }
}

class ApprovalsPage extends StatelessWidget{
  const ApprovalsPage({super.key});
  @override
  Widget build(BuildContext context){
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: CircleAvatar(child: Text('أ')),
          title: Text('طلب إجازة: أحمد سعيد'),
          subtitle: Text('نوع: سنوية • 3 أيام'),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.clear, color: Colors.red),
            SizedBox(width: 8),
            Icon(Icons.check_circle, color: Colors.green),
          ]),
        )
      ],
    );
  }
}

class DashboardPage extends StatelessWidget{
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context){
    return Center(child: Text('إحصائيات الشهر • إجمالي الطلبات: 12 • الموافق عليها: 9 • المرفوضة: 3'));
  }
}

class SettingsPage extends StatelessWidget{
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context){
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(title: Text('الشيفتات الأسبوعية: صباحي / مسائي / ليلي')),
        ListTile(title: Text('إدارة الصلاحيات: 12 تيم ليدر • 5 مشرفين • 5 مشرفين صلاحيات أدمن')),
      ],
    );
  }
}
