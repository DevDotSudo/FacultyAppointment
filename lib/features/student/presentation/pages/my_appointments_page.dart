import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../shared/widgets/dialog_helper.dart';
import '../../../shared/widgets/appointment_tile.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../domain/usecases/cancel_appointment_usecase.dart';

class MyAppointmentsPage extends StatefulWidget {
  const MyAppointmentsPage({super.key});
  @override
  State<MyAppointmentsPage> createState() => _MyAppointmentsPageState();
}

class _MyAppointmentsPageState extends State<MyAppointmentsPage> {
  String _tab = 'All';
  final _tabs = ['All', 'Pending', 'Accepted', 'Completed', 'Rejected', 'Cancelled'];
  final _cancelUseCase = CancelAppointmentUseCase();

  String _firestoreMsg(Object? e) {
    final s = e?.toString() ?? '';
    if (s.contains('requires an index') || s.contains('FAILED_PRECONDITION')) return 'Database index required. Contact administrator.';
    if (s.contains('PERMISSION_DENIED')) return 'Permission denied.';
    if (s.contains('unavailable') || s.contains('network')) return 'No internet connection.';
    return 'Failed to load appointments. Please try again.';
  }

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
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.s12,
                vertical: Responsive.s8,
              ),
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
            .where('student_id', isEqualTo: uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Padding(padding: EdgeInsets.all(Responsive.s24),
              child: Center(child: Text(_firestoreMsg(snapshot.error),
                style: GoogleFonts.inter(fontSize: 13, color: mutedColor), textAlign: TextAlign.center)));
          }
          if (!snapshot.hasData) {
            return LayoutBuilder(builder: (context, box) {
              final cols = box.maxWidth < 400 ? 1 : box.maxWidth < 600 ? 2 : box.maxWidth < 900 ? 3 : 5;
              final gap = 10.0;
              final cardW = (box.maxWidth - gap * (cols - 1)) / cols;
              return Wrap(spacing: gap, runSpacing: gap,
                children: List.generate(cols * 2, (_) => SizedBox(width: cardW, child: const SkeletonAppointmentTile())));
            });
          }
          var docs = snapshot.data!.docs.toList()
            ..sort((a, b) {
              final at = (a['created_at'] as dynamic)?.seconds ?? 0;
              final bt = (b['created_at'] as dynamic)?.seconds ?? 0;
              return (bt as int).compareTo(at as int);
            });
          if (_tab != 'All') {
            docs = docs.where((d) => (d['status'] as String? ?? '').toLowerCase() == _tab.toLowerCase()).toList();
          }
          if (docs.isEmpty) {
            return Padding(padding: EdgeInsets.all(Responsive.s40),
              child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.calendar_today_rounded, size: 48, color: mutedColor),
                SizedBox(height: Responsive.s12),
                Text('No ${_tab == 'All' ? '' : _tab.toLowerCase()} appointments',
                  style: GoogleFonts.inter(fontSize: Responsive.body(screenWidth).fontSize,
                    fontWeight: FontWeight.w600, color: textColor)),
              ])));
          }
          return LayoutBuilder(builder: (context, box) {
            final cols = box.maxWidth < 400 ? 1 : box.maxWidth < 600 ? 2 : box.maxWidth < 900 ? 3 : 5;
            final gap = 10.0;
            final cardW = (box.maxWidth - gap * (cols - 1)) / cols;
            return Column(children: [
              Wrap(spacing: gap, runSpacing: gap,
                children: docs.map((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  final status = d['status'] as String? ?? 'pending';
                  return SizedBox(width: cardW, child: AppointmentTile(
                    name: d['faculty_name'] as String? ?? 'Faculty',
                    dateTime: '${d['date'] ?? ''} · ${d['time'] ?? ''}',
                    purpose: d['purpose'] as String? ?? '',
                    status: status,
                    onTap: () => context.goNamed('student-appointment-detail', extra: doc.id),
                    actionButton: (status == 'pending' || status == 'accepted')
                        ? TextButton(
                            onPressed: () => DialogHelper.showCancelAppointmentModal(context,
                              facultyName: d['faculty_name'] as String? ?? 'Faculty',
                              onConfirm: () async {
                                await _cancelUseCase.call(requestId: doc.id,
                                  facultyId: d['faculty_id'] as String? ?? '',
                                  studentName: FirebaseAuth.instance.currentUser?.displayName ?? 'A student');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Cancelled'), backgroundColor: AppColors.danger));
                                }
                              }),
                            style: TextButton.styleFrom(foregroundColor: AppColors.statusRejected),
                            child: Text('Cancel', style: GoogleFonts.inter(
                              fontSize: Responsive.small(screenWidth).fontSize, fontWeight: FontWeight.w600)))
                        : null,
                  ));
                }).toList()),
              SizedBox(height: Responsive.s8),
              Text('${docs.length} records', style: GoogleFonts.inter(
                fontSize: Responsive.small(screenWidth).fontSize, color: mutedColor)),
            ]);
          });
        },
      ),
    ]);
  }
}