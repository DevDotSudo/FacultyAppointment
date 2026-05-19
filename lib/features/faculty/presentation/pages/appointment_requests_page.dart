import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../shared/widgets/request_tile.dart';
import '../../../shared/widgets/dialog_helper.dart';
import '../../domain/usecases/accept_request_usecase.dart';
import '../../domain/usecases/reject_request_usecase.dart';
import '../../../../core/utils/encryption_service.dart';
import '../../../shared/widgets/skeleton_loader.dart';

class AppointmentRequestsPage extends StatefulWidget {
  const AppointmentRequestsPage({super.key});
  @override
  State<AppointmentRequestsPage> createState() => _AppointmentRequestsPageState();
}

class _AppointmentRequestsPageState extends State<AppointmentRequestsPage> {
  String _tab = 'Pending';
  final _tabs = ['Pending', 'Accepted', 'Rejected', 'Cancelled'];
  final _acceptUseCase = AcceptRequestUseCase();
  final _rejectUseCase = RejectRequestUseCase();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Tab filters
      Wrap(
        spacing: Responsive.s8,
        runSpacing: Responsive.s8,
        children: _tabs.map((tab) {
          final active = tab == _tab;
          return GestureDetector(
            onTap: () => setState(() => _tab = tab),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: Responsive.s12, vertical: Responsive.s8),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : (isDark ? AppColors.darkSurface : Colors.white),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: active ? AppColors.primary : borderColor),
              ),
              child: Text(tab, style: GoogleFonts.inter(
                fontSize: Responsive.small(screenWidth).fontSize,
                fontWeight: FontWeight.w500,
                color: active ? Colors.white : mutedColor)),
            ),
          );
        }).toList(),
      ),
      SizedBox(height: Responsive.s16),
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('appointment_requests')
            .where('faculty_id', isEqualTo: uid).orderBy('created_at', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LayoutBuilder(builder: (context, box) {
              final cols = box.maxWidth < 400 ? 1 : box.maxWidth < 600 ? 2 : box.maxWidth < 900 ? 3 : 5;
              final gap = 10.0;
              final cardW = (box.maxWidth - gap * (cols - 1)) / cols;
              return Wrap(spacing: gap, runSpacing: gap,
                children: List.generate(cols * 2, (_) => SizedBox(width: cardW, child: const SkeletonRequestTile())));
            });
          }
          final filtered = snapshot.data!.docs
              .where((d) => (d['status'] as String? ?? '').toLowerCase() == _tab.toLowerCase()).toList();
          if (filtered.isEmpty) {
            return Padding(padding: EdgeInsets.all(Responsive.s40),
              child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.inbox_rounded, size: 48, color: mutedColor),
                SizedBox(height: Responsive.s12),
                Text('No ${_tab.toLowerCase()} requests', style: GoogleFonts.inter(
                  fontSize: Responsive.body(screenWidth).fontSize,
                  fontWeight: FontWeight.w600, color: textColor)),
              ])));
          }
          return LayoutBuilder(builder: (context, box) {
            final cols = box.maxWidth < 400 ? 1 : box.maxWidth < 600 ? 2 : box.maxWidth < 900 ? 3 : 5;
            final gap = 10.0;
            final cardW = (box.maxWidth - gap * (cols - 1)) / cols;
            return Column(children: [
              Wrap(spacing: gap, runSpacing: gap,
                children: filtered.map((doc) {
                  final d = EncryptionService.decryptFields(doc.data() as Map<String, dynamic>);
                  return SizedBox(width: cardW, child: RequestTile(
                    studentName: d['student_name'] as String? ?? 'Student',
                    dateTime: '${d['date'] ?? ''} · ${d['time'] ?? ''}',
                    purpose: d['purpose'] as String? ?? '',
                    onAccept: _tab == 'Pending' ? () async {
                      await _acceptUseCase.call(requestId: doc.id, studentId: d['student_id'] as String? ?? '');
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Accepted')));
                    } : null,
                    onReject: _tab == 'Pending' ? () async {
                      await _rejectUseCase.call(requestId: doc.id, studentId: d['student_id'] as String? ?? '');
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rejected')));
                    } : null,
                    onView: (_tab == 'Cancelled' || _tab == 'Rejected') ? null : () => DialogHelper.showViewRequestModal(context,
                      studentName: d['student_name'] as String? ?? '', date: d['date'] as String? ?? '',
                      time: d['time'] as String? ?? '', purpose: d['purpose'] as String? ?? '',
                      onAccept: () async => await _acceptUseCase.call(requestId: doc.id, studentId: d['student_id'] as String? ?? ''),
                      onReject: () async => await _rejectUseCase.call(requestId: doc.id, studentId: d['student_id'] as String? ?? '')),
                    onReschedule: _tab == 'Accepted' ? () => _showReschedule(context, doc.id, d) : null,
                  ));
                }).toList()),
              SizedBox(height: Responsive.s8),
              Text('${filtered.length} records', style: GoogleFonts.inter(
                fontSize: Responsive.small(screenWidth).fontSize, color: mutedColor)),
            ]);
          });
        },
      ),
    ]);
  }

  Future<void> _showReschedule(BuildContext context, String docId, Map<String, dynamic> d) async {
    final dateCtrl = TextEditingController(text: d['date'] as String? ?? '');
    final timeCtrl = TextEditingController(text: d['time'] as String? ?? '');
    final confirmed = await DialogHelper.showConfirmDialog(
      context,
      title: 'Reschedule Appointment',
      message: 'Pick a new date and time for ${d['student_name'] ?? 'student'}\'s appointment.',
      confirmLabel: 'Reschedule',
      confirmColor: AppColors.primary,
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: dateCtrl, readOnly: true,
          decoration: InputDecoration(labelText: 'Date', prefixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
          onTap: () async {
            final picked = await showDatePicker(context: context,
              initialDate: DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
            if (picked != null) {
              dateCtrl.text = '${picked.month}/${picked.day}/${picked.year}';
            }
          }),
        const SizedBox(height: 12),
        TextField(controller: timeCtrl, readOnly: true,
          decoration: InputDecoration(labelText: 'Time', prefixIcon: const Icon(Icons.access_time_rounded, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
          onTap: () async {
            final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
            if (picked != null && context.mounted) {
              timeCtrl.text = picked.format(context);
            }
          }),
      ]),
    );
    if (confirmed == true && dateCtrl.text.isNotEmpty && timeCtrl.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('appointment_requests').doc(docId).update({
        'date': dateCtrl.text,
        'time': timeCtrl.text,
        'updated_at': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rescheduled ✓'), backgroundColor: AppColors.success));
      }
    }
  }
}