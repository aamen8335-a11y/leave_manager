import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/app_user.dart';
import '../models/leave_request.dart';
import '../services/firestore_service.dart';

class RequestFormScreen extends StatefulWidget {
  final AppUser user; final FirestoreService fs;
  const RequestFormScreen({super.key, required this.user, required this.fs});

  @override
  State<RequestFormScreen> createState() => _RequestFormScreenState();
}

class _RequestFormScreenState extends State<RequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reason = TextEditingController();
  String _selectedType = 'annual'; // annual | sick | unpaid | other
  DateTime? _start; DateTime? _end;
  bool _submitting = false;

  Future<void> _pick(bool isStart) async {
    final now = DateTime.now();
    final initial = isStart ? (_start ?? now) : (_end ?? _start ?? now);
    final d = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      initialDate: initial,
      helpText: isStart ? 'اختر تاريخ البداية' : 'اختر تاريخ النهاية',
      builder: (ctx, child) => Directionality(textDirection: TextDirection.ltr, child: child!),
    );
    if (d != null) setState(() => isStart ? _start = d : _end = d);
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('yyyy-MM-dd');
    return Scaffold(
      appBar: AppBar(title: const Text('طلب إجازة')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'نوع الإجازة'),
              items: const [
                DropdownMenuItem(value: 'annual', child: Text('سنوية')),
                DropdownMenuItem(value: 'sick', child: Text('مرضية')),
                DropdownMenuItem(value: 'unpaid', child: Text('بدون راتب')),
                DropdownMenuItem(value: 'other', child: Text('أخرى')),
              ],
              onChanged: (v) => setState(() => _selectedType = v ?? 'annual'),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: Text(_start == null ? 'من: غير محدد' : 'من: ${df.format(_start!)}')),
              TextButton(onPressed: () => _pick(true), child: const Text('اختيار')),
            ]),
            Row(children: [
              Expanded(child: Text(_end == null ? 'إلى: غير محدد' : 'إلى: ${df.format(_end!)}')),
              TextButton(onPressed: () => _pick(false), child: const Text('اختيار')),
            ]),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reason,
              decoration: const InputDecoration(labelText: 'سبب الإجازة'),
              maxLines: 4,
              validator: (v) => v == null || v.trim().length < 3 ? 'من فضلك اكتب سببًا أو توضيحًا' : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.send),
              onPressed: _submitting
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate() || _start == null || _end == null) return;
                      setState(() => _submitting = true);
                      final now = DateTime.now();
                      final r = LeaveRequest(
                        id: 'temp',
                        userId: widget.user.uid,
                        userName: widget.user.displayName,
                        startDate: _start!,
                        endDate: _end!,
                        type: _selectedType,
                        reason: _reason.text.trim(),
                        status: LeaveStatus.pending,
                        department: widget.user.department,
                        teamId: widget.user.teamId,
                        createdAt: now,
                        updatedAt: now,
                      );
                      await widget.fs.create(r);
                      if (!mounted) return;
                      Navigator.of(context).pop();
                    },
              label: const Text('إرسال الطلب'),
            )
          ],
        ),
      ),
    );
  }
}
