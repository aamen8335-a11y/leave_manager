import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/leave_request.dart';
import '../widgets/leave_card.dart';
import '../services/report_service.dart';
import 'dashboard_screen.dart';
import 'request_form_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppUser user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final fs = Provider.of<FirestoreService>(context, listen: false);
    final auth = Provider.of<AuthService>(context, listen: false);

    final isApprover = widget.user.role == 'admin' || widget.user.role == 'team_leader' || widget.user.role == 'supervisor' || widget.user.isCompanyAdmin;
    final canExport = widget.user.role == 'supervisor' || widget.user.isCompanyAdmin;
    final isSettingsAllowed = widget.user.role == 'admin' || widget.user.isCompanyAdmin;

    final tabs = [
      _MyRequests(fs: fs, userId: widget.user.uid),
      _NewRequest(user: widget.user, fs: fs),
      if (isApprover) _Approvals(fs: fs, approver: widget.user),
      if (isApprover) DashboardScreen(currentUser: widget.user),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام الإجازات'),
        actions: [
          if (canExport)
            IconButton(
              tooltip: 'تصدير CSV (تحديد نطاق)',
              onPressed: () async => _exportWithRange(context),
              icon: const Icon(Icons.download)),
          if (isSettingsAllowed)
            IconButton(
              tooltip: 'إعدادات الشِفتات',
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SettingsScreen(currentUser: widget.user))),
              icon: const Icon(Icons.settings)),
          IconButton(onPressed: () async { await auth.signOut(); if (mounted) Navigator.of(context).pushReplacementNamed('/'); }, icon: const Icon(Icons.logout))
        ],
      ),
      body: tabs[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.list_alt), label: 'طلباتي'),
          const NavigationDestination(icon: Icon(Icons.add_circle), label: 'طلب جديد'),
          if (isApprover) const NavigationDestination(icon: Icon(Icons.verified), label: 'الموافقات'),
          if (isApprover) const NavigationDestination(icon: Icon(Icons.pie_chart), label: 'لوحة التحكم'),
        ],
      ),
    );
  }

  Future<void> _exportWithRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDateRange: DateTimeRange(start: DateTime(now.year, now.month, 1), end: DateTime(now.year, now.month + 1, 0)),
      helpText: 'اختر نطاق التاريخ للتقرير',
      builder: (ctx, child) => Directionality(textDirection: TextDirection.ltr, child: child!),
    );
    if (picked == null) return;

    String? status; String? dept; String? team;
    await showDialog(context: context, builder: (ctx) {
      return AlertDialog(
        title: const Text('فلاتر التقرير (اختياري)'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String>(decoration: const InputDecoration(labelText: 'الحالة'), items: const [
            DropdownMenuItem(value: 'approved', child: Text('معتمد')),
            DropdownMenuItem(value: 'rejected', child: Text('مرفوض')),
            DropdownMenuItem(value: 'pending', child: Text('قيد الانتظار')),
          ], onChanged: (v){ status = v; }),
          TextFormField(decoration: const InputDecoration(labelText: 'الشِفت (Morning/Evening/Night)'), onChanged: (v){ dept = v.trim().isEmpty? null : v.trim(); }),
          TextFormField(decoration: const InputDecoration(labelText: 'الفريق (Team-..)'), onChanged: (v){ team = v.trim().isEmpty? null : v.trim(); }),
        ]),
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(onPressed: ()=> Navigator.pop(ctx), child: const Text('متابعة')),
        ],
      );
    });

    await ReportService().exportCSV(start: picked.start, end: picked.end, status: status, department: dept, teamId: team);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنشاء/حفظ تقرير CSV')));
  }
}

class _MyRequests extends StatelessWidget {
  final FirestoreService fs; final String userId;
  const _MyRequests({required this.fs, required this.userId});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: fs.myRequests(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final items = snapshot.data as List<LeaveRequest>;
        if (items.isEmpty) return const Center(child: Text('لا توجد طلبات بعد'));
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) => LeaveCard(req: items[i]),
        );
      },
    );
  }
}

class _NewRequest extends StatelessWidget {
  final AppUser user; final FirestoreService fs;
  const _NewRequest({required this.user, required this.fs});
  @override
  Widget build(BuildContext context) => Center(
        child: FilledButton.icon(
          icon: const Icon(Icons.note_add),
          label: const Text('إنشاء طلب إجازة'),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_)=> RequestFormScreen(user: user, fs: fs))),
        ),
      );
}

class _Approvals extends StatelessWidget {
  final FirestoreService fs; final AppUser approver;
  const _Approvals({required this.fs, required this.approver});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: fs.pendingRequestsFor(approver),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final items = snapshot.data as List<LeaveRequest>;
        if (items.isEmpty) return const Center(child: Text('لا توجد طلبات قيد الانتظار'));
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) => LeaveCard(req: items[i], approver: approver),
        );
      },
    );
  }
}
