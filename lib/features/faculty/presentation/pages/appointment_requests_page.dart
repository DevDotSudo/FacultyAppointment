import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/request_tile.dart';
import '../../../shared/widgets/dialog_helper.dart';

class AppointmentRequestsPage extends StatefulWidget {
  const AppointmentRequestsPage({super.key});
  @override
  State<AppointmentRequestsPage> createState() => _AppointmentRequestsPageState();
}

class _AppointmentRequestsPageState extends State<AppointmentRequestsPage> {
  String _tab = 'Pending';
  final _tabs = ['Pending', 'Accepted', 'Rejected', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.textDark;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.textMuted;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Appointment Requests', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
      const SizedBox(height: 4),
      Text('Review and respond to student appointment requests', style: GoogleFonts.inter(fontSize: 13, color: mutedColor)),
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
            .where('faculty_id', isEqualTo: uid)
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final filtered = snapshot.data!.docs
              .where((d) => (d['status'] as String? ?? '').toLowerCase() == _tab.toLowerCase())
              .toList();

          if (filtered.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(40),
              child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.inbox_rounded, size: 48, color: mutedColor),
                const SizedBox(height: 12),
                Text('No ${_tab.toLowerCase()} requests', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: textColor)),
              ])),
            );
          }

          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ...filtered.map((doc) {
              final d = doc.data() as Map<String, dynamic>;
              return RequestTile(
                studentName: d['student_name'] as String? ?? 'Student',
                dateTime: '${d['date'] ?? ''} · ${d['time'] ?? ''}',
                purpose: d['purpose'] as String? ?? '',
                onAccept: _tab == 'Pending' ? () {
                  doc.reference.update({'status': 'accepted'});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Request accepted ✓'), backgroundColor: AppColors.success));
                } : null,
                onReject: _tab == 'Pending' ? () {
                  doc.reference.update({'status': 'rejected'});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Request rejected'), backgroundColor: AppColors.danger));
                } : null,
                onView: () => DialogHelper.showViewRequestModal(context,
                  studentName: d['student_name'] as String? ?? 'Student',
                  date: d['date'] as String? ?? '',
                  time: d['time'] as String? ?? '',
                  purpose: d['purpose'] as String? ?? '',
                  onAccept: () => doc.reference.update({'status': 'accepted'}),
                  onReject: () => doc.reference.update({'status': 'rejected'}),
                ),
              );
            }),
            const SizedBox(height: 8),
            Text('${filtered.length} record${filtered.length == 1 ? '' : 's'}',
              style: GoogleFonts.inter(fontSize: 12, color: mutedColor)),
          ]);
        },
      ),
    ]);
  }
}
