import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../shared/widgets/dialog_helper.dart';
import '../../../shared/widgets/appointment_tile.dart';
import '../../domain/usecases/cancel_appointment_usecase.dart';

class MyAppointmentsPage extends StatefulWidget {
  const MyAppointmentsPage({super.key});
  @override
  State<MyAppointmentsPage> createState() => _MyAppointmentsPageState();
}

class _MyAppointmentsPageState extends State<MyAppointmentsPage> {
  String _tab = 'All';
  final _tabs = ['All', 'Pending', 'Accepted', 'Rejected', 'Cancelled'];
  final _cancelUseCase = CancelAppointmentUseCase();

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
            .where('student_id', isEqualTo: uid).orderBy('created_at', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var docs = snapshot.data!.docs;
          if (_tab != 'All') {
            docs = docs.where((d) => (d['status'] as String? ?? '').toLowerCase() == _tab.toLowerCase()).toList();
          }
          if (docs.isEmpty) {
            return Padding(padding: EdgeInsets.all(Responsive.s40),
              child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.calendar_today_rounded, size: 48, color: mutedColor),
                SizedBox(height: Responsive.s12),
                Text('No ${_tab == 'All' ? '' : _tab.toLowerCase()} appointments',
                  style: GoogleFonts.inter(
                    fontSize: Responsive.body(screenWidth).fontSize,
                    fontWeight: FontWeight.w600,
                    color: textColor)),
              ])));
          }
          return Column(children: [
            ...docs.map((doc) {
              final d = doc.data() as Map<String, dynamic>;
              final status = d['status'] as String? ?? 'pending';
              return Padding(
                padding: EdgeInsets.only(bottom: Responsive.s8),
                child: AppointmentTile(
                  name: d['faculty_name'] as String? ?? 'Faculty',
                  dateTime: '${d['date'] ?? ''} · ${d['time'] ?? ''}',
                  purpose: d['purpose'] as String? ?? '',
                  status: status,
                  actionButton: status == 'pending'
                      ? TextButton(
                          onPressed: () => DialogHelper.showCancelAppointmentModal(context,
                            facultyName: d['faculty_name'] as String? ?? 'Faculty',
                            onConfirm: () async {
                              await _cancelUseCase.call(
                                requestId: doc.id,
                                facultyId: d['faculty_id'] as String? ?? '',
                                studentName: FirebaseAuth.instance.currentUser?.displayName ?? 'A student',
                              );
                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Cancelled'), backgroundColor: AppColors.danger));
                            }),
                          style: TextButton.styleFrom(foregroundColor: AppColors.statusRejected),
                          child: Text('Cancel', style: GoogleFonts.inter(
                            fontSize: Responsive.small(screenWidth).fontSize,
                            fontWeight: FontWeight.w600)),
                        )
                      : null,
                ),
              );
            }),
            SizedBox(height: Responsive.s8),
            Text('${docs.length} records', style: GoogleFonts.inter(
              fontSize: Responsive.small(screenWidth).fontSize,
              color: mutedColor)),
          ]);
        },
      ),
    ]);
  }
}