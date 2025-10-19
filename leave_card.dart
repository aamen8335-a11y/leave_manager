import 'package:flutter/material.dart';
import '../models/leave_request.dart';
import '../models/app_user.dart';
import '../services/firestore_service.dart';

String arabicType(String type){
  switch(type){
    case 'annual': return 'سنوية';
    case 'sick': return 'مرضية';
    case 'unpaid': return 'بدون راتب';
    default: return 'أخرى';
  }
}

class LeaveCard extends StatelessWidget {
  final LeaveRequest req; final AppUser? approver;
  const LeaveCard({super.key, required this.req, this.approver});

  Color _statusColor() {
    switch (req.status) {
      case LeaveStatus.approved: return Colors.green;
      case LeaveStatus.rejected: return Colors.red;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(req.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
            Chip(label: Text(req.status.name.toUpperCase()), backgroundColor: _statusColor().withOpacity(0.15))
          ]),
          const SizedBox(height: 8),
          Text('النوع: ${arabicType(req.type)}'),
          Text('من: ${req.startDate.toLocal().toString().split(' ').first}  إلى: ${req.endDate.toLocal().toString().split(' ').first}'),
          const SizedBox(height: 6),
          Text('السبب: ${req.reason}'),
          if (req.approverNote != null && req.approverNote!.isNotEmpty) Text('ملاحظة: ${req.approverNote!}'),
          if (approver != null) _ApprovalActions(req: req, approver: approver!),
        ]),
      ),
    );
  }
}

class _ApprovalActions extends StatefulWidget {
  final LeaveRequest req; final AppUser approver;
  const _ApprovalActions({required this.req, required this.approver});
  @override
  State<_ApprovalActions> createState() => _ApprovalActionsState();
}

class _ApprovalActionsState extends State<_ApprovalActions> {
  final _note = TextEditingController();
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Divider(),
        TextField(controller: _note, decoration: const InputDecoration(labelText: 'ملاحظة للموظف (اختياري)')),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          TextButton(
            onPressed: _busy ? null : () async {
              setState(() => _busy = true);
              await fs.updateStatus(widget.req.id, 'rejected',
                  approverId: widget.approver.uid,
                  approverName: widget.approver.displayName,
                  approverNote: _note.text.trim());
              if (mounted) setState(() => _busy = false);
            },
            child: const Text('رفض'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: _busy ? null : () async {
              setState(() => _busy = true);
              await fs.updateStatus(widget.req.id, 'approved',
                  approverId: widget.approver.uid,
                  approverName: widget.approver.displayName,
                  approverNote: _note.text.trim());
              if (mounted) setState(() => _busy = false);
            },
            child: const Text('موافقة'),
          )
        ])
      ],
    );
  }
}
