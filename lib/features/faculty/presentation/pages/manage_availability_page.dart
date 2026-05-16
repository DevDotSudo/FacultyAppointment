import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/dialog_helper.dart';
import '../../domain/usecases/manage_availability_usecase.dart';

class ManageAvailabilityPage extends StatelessWidget {
  const ManageAvailabilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.textDark;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.textMuted;
    final useCase = ManageAvailabilityUseCase();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Manage Availability', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 4),
          Text('Set your available time slots for appointments', style: GoogleFonts.inter(fontSize: 13, color: mutedColor)),
        ])),
        ElevatedButton.icon(
          onPressed: () => DialogHelper.showAddScheduleModal(context,
            onSave: (day, start, end) async {
              try {
                await useCase.addSchedule(facultyId: uid, day: day, startTime: start, endTime: end);
                if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Schedule added ✓'), backgroundColor: AppColors.success)); }
              } catch (e) {
                if (context.mounted) { DialogHelper.showErrorDialog(context, title: 'Error', message: e.toString()); }
              }
            }),
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text('Add Slot'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ]),
      const SizedBox(height: 20),

      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('faculty_availability')
            .where('faculty_id', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final schedule = snapshot.data!.docs;

          if (schedule.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFEEEFF2)),
              ),
              child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.schedule_rounded, size: 48, color: mutedColor),
                const SizedBox(height: 12),
                Text('No availability set', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: textColor)),
                const SizedBox(height: 4),
                Text('Click "Add Slot" to add your first time slot', style: GoogleFonts.inter(fontSize: 13, color: mutedColor)),
              ])),
            );
          }

          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFEEEFF2)),
              boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBg : const Color(0xFFF8F9FB),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  border: Border(bottom: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFEEEFF2))),
                ),
                child: Row(children: [
                  Expanded(flex: 2, child: Text('Day', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: mutedColor))),
                  Expanded(flex: 2, child: Text('Start', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: mutedColor))),
                  Expanded(flex: 2, child: Text('End', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: mutedColor))),
                  const SizedBox(width: 72),
                ]),
              ),
              ...schedule.asMap().entries.map((entry) {
                final i = entry.key;
                final doc = entry.value;
                final d = doc.data() as Map<String, dynamic>;
                final isLast = i == schedule.length - 1;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: isLast ? null : Border(bottom: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFF0F1F3))),
                  ),
                  child: Row(children: [
                    Expanded(flex: 2, child: Row(children: [
                      Container(width: 8, height: 8,
                        decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(d['day'] as String? ?? '', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: textColor)),
                    ])),
                    Expanded(flex: 2, child: Text(d['start_time'] as String? ?? '', style: GoogleFonts.inter(fontSize: 13, color: textColor))),
                    Expanded(flex: 2, child: Text(d['end_time'] as String? ?? '', style: GoogleFonts.inter(fontSize: 13, color: textColor))),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                        onPressed: () => DialogHelper.showAddScheduleModal(context,
                          initialDay: d['day'] as String?,
                          initialStart: d['start_time'] as String?,
                          initialEnd: d['end_time'] as String?,
                          onSave: (day, start, end) async {
                            try {
                              await useCase.updateSchedule(scheduleId: doc.id, day: day, startTime: start, endTime: end);
                              if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Schedule updated'), backgroundColor: AppColors.primary)); }
                            } catch (e) {
                              if (context.mounted) { DialogHelper.showErrorDialog(context, title: 'Error', message: e.toString()); }
                            }
                          }),
                        icon: Icon(Icons.edit_rounded, size: 16, color: AppColors.primary),
                        constraints: const BoxConstraints(), padding: const EdgeInsets.all(6),
                      ),
                      IconButton(
                        onPressed: () => DialogHelper.showDeleteScheduleModal(context,
                          day: d['day'] as String? ?? '',
                          startTime: d['start_time'] as String? ?? '',
                          endTime: d['end_time'] as String? ?? '',
                          onConfirm: () async {
                            try {
                              await useCase.deleteSchedule(scheduleId: doc.id);
                              if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Schedule deleted'), backgroundColor: AppColors.danger)); }
                            } catch (e) {
                              if (context.mounted) { DialogHelper.showErrorDialog(context, title: 'Error', message: e.toString()); }
                            }
                          }),
                        icon: Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.danger),
                        constraints: const BoxConstraints(), padding: const EdgeInsets.all(6),
                      ),
                    ]),
                  ]),
                );
              }),
            ]),
          );
        },
      ),
    ]);
  }
}
