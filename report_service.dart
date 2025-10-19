import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/app_user.dart';

class ReportService {
  final _reqs = FirebaseFirestore.instance.collection('leave_requests');

  Future<void> exportCSV({
    required DateTime start,
    required DateTime end,
    AppUser? requester,
    String? department,
    String? teamId,
    String? status, // approved|rejected|pending
  }) async {
    Query q = _reqs
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end));

    if (status != null) q = q.where('status', isEqualTo: status);
    if (department != null) q = q.where('department', isEqualTo: department);
    if (teamId != null) q = q.where('teamId', isEqualTo: teamId);

    final snap = await q.get();

    final rows = <List<dynamic>>[
      ['الموظف','من','إلى','النوع','الحالة','الشِفت','الفريق','المعتمد','ملاحظة']
    ];
    final df = DateFormat('yyyy-MM-dd');

    for (final d in snap.docs) {
      final m = d.data();
      rows.add([
        m['userName'] ?? '',
        df.format((m['startDate'] as Timestamp).toDate()),
        df.format((m['endDate'] as Timestamp).toDate()),
        m['type'] ?? '',
        m['status'] ?? '',
        m['department'] ?? '',
        m['teamId'] ?? '',
        m['approverName'] ?? '',
        m['approverNote'] ?? ''
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/leave_report_${start.year}_${start.month}_${end.year}_${end.month}.csv');
    await file.writeAsString(csv, flush: true);
    await Share.shareXFiles([XFile(file.path)], text: 'تقرير الإجازات');
  }

  Future<void> exportCurrentMonthCSV(AppUser requester) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));
    await exportCSV(start: start, end: end, requester: requester, status: 'approved');
  }
}
