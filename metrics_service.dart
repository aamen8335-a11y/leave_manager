import 'package:cloud_firestore/cloud_firestore.dart';

class MetricsService {
  final _reqs = FirebaseFirestore.instance.collection('leave_requests');

  Future<Map<String, dynamic>> monthMetrics(DateTime monthStart, {String? type}) async {
    final start = DateTime(monthStart.year, monthStart.month, 1);
    final end = DateTime(monthStart.year, monthStart.month + 1, 1).subtract(const Duration(seconds: 1));

    Query q = _reqs
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end));
    if (type != null && type.isNotEmpty) q = q.where('type', isEqualTo: type);

    final snap = await q.get();

    int pending = 0, approved = 0, rejected = 0;
    final byShift = <String, int>{};
    final byTeam = <String, int>{};

    for (final d in snap.docs) {
      final m = d.data();
      final status = (m['status'] ?? 'pending') as String;
      if (status == 'approved') approved++; else if (status == 'rejected') rejected++; else pending++;
      final dept = (m['department'] ?? 'NA') as String; byShift[dept] = (byShift[dept] ?? 0) + 1;
      final team = (m['teamId'] ?? 'NA') as String; byTeam[team] = (byTeam[team] ?? 0) + 1;
    }

    return {
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
      'byShift': byShift,
      'byTeam': byTeam,
    };
  }
}
