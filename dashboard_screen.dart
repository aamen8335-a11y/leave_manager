import 'package:flutter/material.dart';
import '../services/metrics_service.dart';
import '../models/app_user.dart';

class DashboardScreen extends StatefulWidget {
  final AppUser currentUser;
  const DashboardScreen({super.key, required this.currentUser});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? data; bool loading = true;
  String? typeFilter; // annual, sick, unpaid, ...

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState((){ loading = true; });
    final svc = MetricsService();
    final m = await svc.monthMetrics(DateTime.now(), type: typeFilter);
    if (!mounted) return; setState(() { data = m; loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            Expanded(child: Text('لوحة التحكم', style: Theme.of(context).textTheme.titleLarge)),
            const SizedBox(width: 8),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String>(
                value: typeFilter,
                hint: const Text('فلتر نوع الإجازة'),
                items: const [
                  DropdownMenuItem(value: 'annual', child: Text('سنوية')),
                  DropdownMenuItem(value: 'sick', child: Text('مرضية')),
                  DropdownMenuItem(value: 'unpaid', child: Text('بدون راتب')),
                  DropdownMenuItem(value: 'other', child: Text('أخرى')),
                ],
                onChanged: (v){ setState(()=> typeFilter = v); _load(); },
              ),
            )
          ]),
          const SizedBox(height: 12),
          if (loading || data == null) const Center(child: CircularProgressIndicator()) else ...[
            _statCard('قيد الانتظار', data!['pending'] as int),
            _statCard('معتمد', data!['approved'] as int),
            _statCard('مرفوض', data!['rejected'] as int),
            const SizedBox(height: 16),
            Text('حسب الشِفت', style: Theme.of(context).textTheme.titleMedium),
            ..._mapToChips((data!['byShift'] as Map).cast<String,int>()),
            const SizedBox(height: 16),
            Text('حسب الفريق', style: Theme.of(context).textTheme.titleMedium),
            ..._mapToChips((data!['byTeam'] as Map).cast<String,int>()),
          ]
        ],
      ),
    );
  }

  Widget _statCard(String title, int value) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[
        Text(title), Text(value.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
      ]),
    ),
  );

  List<Widget> _mapToChips(Map<String,int> m) => m.entries.map((e)=> Padding(
    padding: const EdgeInsets.only(top:8.0),
    child: Chip(label: Text('${e.key}: ${e.value}')),
  )).toList();
}
