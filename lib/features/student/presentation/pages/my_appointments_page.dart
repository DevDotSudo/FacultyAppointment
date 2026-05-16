import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
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
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.textDark;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.textMuted;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('My Appointments', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
      const SizedBox(height: 4),
      Text('Track and manage your appointment requests', style: GoogleFonts.inter(fontSize: 13, color: mutedColor)),
      const SizedBox(height: 20),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _tabs.map((tab) {
            final active = tab == _tab;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _tab = tab),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : (isDark ? AppColors.darkCard : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? AppColors.primary : (isDark ? AppColors.darkBorder : const Color(0xFFEEEFF2))),
                  ),
                  child: Text(tab, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600,
                    color: active ? Colors.white : mutedColor)),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 16),
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointment_requests')
            .where('student_id', isEqualTo: uid)
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var docs = snapshot.data!.docs;
          if (_tab != 'All') {
            docs = docs.where((d) => (d['status'] as String? ?? '').toLowerCase() == _tab.toLowerCase()).toList();
          }
          if (docs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(40),
              child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.calendar_today_rounded, size: 48, color: mutedColor),
                const SizedBox(height: 12),
                Text('No ${_tab == 'All' ? '' : _tab.toLowerCase()} appointments',
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: textColor)),
              ])),
            );
          }
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ...docs.map((doc) {
              final d = doc.data() as Map<String, dynamic>;
              final status = d['status'] as String? ?? 'pending';
              return AppointmentTile(
                name: d['faculty_name'] as String? ?? 'Faculty',
                dateTime: '${d['date'] ?? ''} · ${d['time'] ?? ''}',
                purpose: d['purpose'] as String? ?? '',
                status: status,
                actionButton: status == 'pending'
                    ? TextButton(
                        onPressed: () => DialogHelper.showCancelAppointmentModal(context,
                          facultyName: d['faculty_name'] as String? ?? 'Faculty',
                          onConfirm: () async {
                            try {
                              await _cancelUseCase.call(requestId: doc.id);
                              if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Appointment cancelled'), backgroundColor: AppColors.danger)); }
                            } catch (e) {
                              if (context.mounted) { DialogHelper.showErrorDialog(context, title: 'Error', message: e.toString()); }
                            }
                          }),
                        style: TextButton.styleFrom(foregroundColor: AppColors.danger, padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        child: Text('Cancel', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
                      )
                    : null,
              );
            }),
            const SizedBox(height: 8),
            Text('${docs.length} record${docs.length == 1 ? '' : 's'}',
              style: GoogleFonts.inter(fontSize: 12, color: mutedColor)),
          ]);
        },
      ),
    ]);
  }
}
