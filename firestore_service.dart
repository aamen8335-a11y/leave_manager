import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leave_request.dart';
import '../models/app_user.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  CollectionReference get _reqs => _db.collection('leave_requests');
  CollectionReference get _users => _db.collection('users');

  Stream<List<LeaveRequest>> myRequests(String userId) => _reqs
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => LeaveRequest.fromDoc(d)).toList());

  Stream<List<LeaveRequest>> pendingRequestsFor(AppUser approver) {
    Query q = _reqs.where('status', isEqualTo: 'pending');
    if ((approver.role == 'team_leader') && approver.teamId != null) {
      q = q.where('teamId', isEqualTo: approver.teamId);
    } else if ((approver.role == 'supervisor') && approver.department != null) {
      q = q.where('department', isEqualTo: approver.department);
    } else if (approver.role == 'admin' || approver.isCompanyAdmin) {
      // no extra filter
    } else {
      q = q.where('userId', isEqualTo: '__none__');
    }

    return q.orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => LeaveRequest.fromDoc(d)).toList());
  }

  Future<void> create(LeaveRequest r) async { await _reqs.add(r.toMap()); }

  Future<void> updateStatus(String id, String status, {String? approverId, String? approverName, String? approverNote}) async {
    await _reqs.doc(id).update({
      'status': status,
      'approverId': approverId,
      'approverName': approverName,
      'approverNote': approverNote,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Settings helpers
  Stream<List<AppUser>> usersStream({List<String>? roles}) {
    Query q = _users;
    if (roles != null && roles.isNotEmpty) q = q.where('role', whereIn: roles);
    return q.snapshots().map((s) => s.docs.map((d) => AppUser.fromMap(d.id, d.data() as Map<String,dynamic>)).toList());
  }

  Future<void> updateUserFields(String uid, {String? department, String? teamId}) async {
    final data = <String, dynamic>{};
    if (department != null) data['department'] = department;
    if (teamId != null) data['teamId'] = teamId;
    if (data.isNotEmpty) await _users.doc(uid).update(data);
  }
}
