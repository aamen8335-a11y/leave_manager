import 'package:cloud_firestore/cloud_firestore.dart';

enum LeaveStatus { pending, approved, rejected }

class LeaveRequest {
  final String id;
  final String userId;
  final String userName;
  final DateTime startDate;
  final DateTime endDate;
  final String type; // annual, sick, unpaid, other
  final String reason;
  final LeaveStatus status;
  final String? approverId;
  final String? approverName;
  final String? approverNote;
  final String? department; // shift scope
  final String? teamId; // team scope
  final DateTime createdAt;
  final DateTime updatedAt;

  LeaveRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.reason,
    required this.status,
    this.approverId,
    this.approverName,
    this.approverNote,
    this.department,
    this.teamId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeaveRequest.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return LeaveRequest(
      id: doc.id,
      userId: d['userId'],
      userName: d['userName'] ?? '',
      startDate: (d['startDate'] as Timestamp).toDate(),
      endDate: (d['endDate'] as Timestamp).toDate(),
      type: d['type'] ?? 'annual',
      reason: d['reason'] ?? '',
      status: _statusFromString(d['status'] ?? 'pending'),
      approverId: d['approverId'],
      approverName: d['approverName'],
      approverNote: d['approverNote'],
      department: d['department'],
      teamId: d['teamId'],
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'type': type,
        'reason': reason,
        'status': status.name,
        'approverId': approverId,
        'approverName': approverName,
        'approverNote': approverNote,
        if (department != null) 'department': department,
        if (teamId != null) 'teamId': teamId,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  static LeaveStatus _statusFromString(String s) {
    switch (s) {
      case 'approved':
        return LeaveStatus.approved;
      case 'rejected':
        return LeaveStatus.rejected;
      default:
        return LeaveStatus.pending;
    }
  }
}
