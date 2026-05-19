import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/dialog_helper.dart';
import '../../../shared/widgets/skeleton_loader.dart';
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
          Text('Manage Availability',
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 4),
          Text('Set your available consultation schedules',
              style: GoogleFonts.inter(fontSize: 13, color: mutedColor)),
        ])),
        ElevatedButton.icon(
          onPressed: () {
            DialogHelper.showAddScheduleModal(
              context,
              onSave: (day, startTime, endTime, {
                DateTime? date,
                String consultationType = 'face-to-face',
                String locationOrLink = '',
                int maxSlots = 1,
              }) async {
                try {
                  await useCase.addSchedule(
                    facultyId: uid,
                    day: day,
                    startTime: startTime,
                    endTime: endTime,
                    date: date,
                    consultationType: consultationType,
                    locationOrLink: locationOrLink,
                    maxSlots: maxSlots,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Schedule added ✓'), backgroundColor: AppColors.success),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add schedule: $e'), backgroundColor: AppColors.danger),
                    );
                  }
                }
              },
            );
          },
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text('Add Schedule'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          if (snapshot.hasError) {
            final msg = snapshot.error?.toString() ?? '';
            final friendly = msg.contains('requires an index') || msg.contains('FAILED_PRECONDITION')
                ? 'Database index required. Please contact the administrator.'
                : msg.contains('PERMISSION_DENIED')
                    ? 'Permission denied.'
                    : 'Failed to load schedules. Please try again.';
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text(friendly,
                  style: GoogleFonts.inter(fontSize: 13, color: mutedColor), textAlign: TextAlign.center)),
            );
          }
          if (!snapshot.hasData) {
            return LayoutBuilder(builder: (context, box) {
              final cols = box.maxWidth < 400 ? 1 : box.maxWidth < 600 ? 2 : box.maxWidth < 900 ? 3 : 5;
              final gap = 10.0;
              final cardW = (box.maxWidth - gap * (cols - 1)) / cols;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: List.generate(cols * 2, (_) => SizedBox(
                  width: cardW,
                  child: const SkeletonScheduleItem(),
                )),
              );
            });
          }
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
                Text('No schedules set',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: textColor)),
                const SizedBox(height: 4),
                Text('Click "Add Schedule" to create your first consultation slot',
                    style: GoogleFonts.inter(fontSize: 13, color: mutedColor), textAlign: TextAlign.center),
              ])),
            );
          }

          return LayoutBuilder(builder: (context, box) {
            final cols = box.maxWidth < 400 ? 1 : box.maxWidth < 600 ? 2 : box.maxWidth < 900 ? 3 : 5;
            final gap = 10.0;
            final cardW = (box.maxWidth - gap * (cols - 1)) / cols;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: schedule.map((doc) {
                final d = doc.data() as Map<String, dynamic>;
                final bookedSlots = (d['booked_slots'] as num?)?.toInt() ?? 0;
                final maxSlots = (d['max_slots'] as num?)?.toInt() ?? 1;
                final remaining = maxSlots - bookedSlots;
                final isFullyBooked = remaining <= 0;
                final consultationType = d['consultation_type'] as String? ?? 'face-to-face';
                final isOnline = consultationType == 'online';

                DateTime? date;
                final rawDate = d['date'];
                if (rawDate is Timestamp) date = rawDate.toDate();

                return SizedBox(
                  width: cardW,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isFullyBooked
                            ? AppColors.danger.withValues(alpha: 0.3)
                            : (isDark ? AppColors.darkBorder : const Color(0xFFEEEFF2)),
                      ),
                      boxShadow: isDark
                          ? null
                          : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      // Badges row
                      Row(children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: isOnline
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(isOnline ? Icons.videocam_rounded : Icons.location_on_rounded,
                                size: 11, color: isOnline ? AppColors.primary : AppColors.success),
                              const SizedBox(width: 3),
                              Flexible(child: Text(isOnline ? 'Online' : 'F2F',
                                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600,
                                  color: isOnline ? AppColors.primary : AppColors.success),
                                overflow: TextOverflow.ellipsis)),
                            ]),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: isFullyBooked
                                ? AppColors.danger.withValues(alpha: 0.1)
                                : AppColors.statusAccepted.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            isFullyBooked ? 'Full' : '$remaining/$maxSlots',
                            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600,
                              color: isFullyBooked ? AppColors.danger : AppColors.statusAccepted),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      // Day / Date
                      Text(
                        date != null
                            ? DateFormat('EEE, MMM d').format(date)
                            : (d['day'] as String? ?? ''),
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: textColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      // Time
                      Row(children: [
                        Icon(Icons.access_time_rounded, size: 12, color: mutedColor),
                        const SizedBox(width: 4),
                        Expanded(child: Text(
                          '${d['start_time'] ?? ''} – ${d['end_time'] ?? ''}',
                          style: GoogleFonts.inter(fontSize: 11, color: mutedColor),
                          overflow: TextOverflow.ellipsis,
                        )),
                      ]),
                      if ((d['location_or_link'] as String? ?? '').isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(children: [
                          Icon(isOnline ? Icons.link_rounded : Icons.place_rounded, size: 12, color: mutedColor),
                          const SizedBox(width: 4),
                          Expanded(child: Text(d['location_or_link'] as String,
                            style: GoogleFonts.inter(fontSize: 10, color: mutedColor),
                            overflow: TextOverflow.ellipsis)),
                        ]),
                      ],
                      const SizedBox(height: 8),
                      // Actions row
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        _actionIcon(
                          icon: (d['is_active'] as bool? ?? true) ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                          color: (d['is_active'] as bool? ?? true) ? AppColors.success : AppColors.darkTextSecondary,
                          size: 20,
                          tooltip: (d['is_active'] as bool? ?? true) ? 'Set inactive' : 'Set active',
                          onTap: () async {
                            final isActive = d['is_active'] as bool? ?? true;
                            await FirebaseFirestore.instance
                                .collection('faculty_availability').doc(doc.id)
                                .update({'is_active': !isActive});
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(isActive ? 'Set to inactive' : 'Set to active'),
                                backgroundColor: isActive ? AppColors.warning : AppColors.success,
                              ));
                            }
                          },
                        ),
                        const SizedBox(width: 2),
                        _actionIcon(
                          icon: Icons.edit_rounded, color: AppColors.primary, size: 14,
                          tooltip: 'Edit',
                          onTap: () {
                            DialogHelper.showAddScheduleModal(context,
                              initialDay: d['day'] as String? ?? 'Monday',
                              initialStart: d['start_time'] as String?,
                              initialEnd: d['end_time'] as String?,
                              initialDate: date,
                              initialConsultationType: d['consultation_type'] as String?,
                              initialLocationOrLink: d['location_or_link'] as String?,
                              initialMaxSlots: (d['max_slots'] as num?)?.toInt(),
                              onSave: (day, startTime, endTime, {
                                DateTime? date,
                                String consultationType = 'face-to-face',
                                String locationOrLink = '',
                                int maxSlots = 1,
                              }) async {
                                try {
                                  await useCase.updateSchedule(
                                    scheduleId: doc.id, day: day,
                                    startTime: startTime, endTime: endTime,
                                    date: date, consultationType: consultationType,
                                    locationOrLink: locationOrLink, maxSlots: maxSlots,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Updated ✓'), backgroundColor: AppColors.success));
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.danger));
                                  }
                                }
                              },
                            );
                          },
                        ),
                        const SizedBox(width: 2),
                        _actionIcon(
                          icon: Icons.delete_outline_rounded, color: AppColors.danger, size: 14,
                          tooltip: 'Delete',
                          onTap: () => DialogHelper.showDeleteScheduleModal(context,
                            day: d['day'] as String? ?? '',
                            startTime: d['start_time'] as String? ?? '',
                            endTime: d['end_time'] as String? ?? '',
                            onConfirm: () async {
                              await useCase.deleteSchedule(scheduleId: doc.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Deleted'), backgroundColor: AppColors.danger));
                              }
                            }),
                        ),
                      ]),
                    ]),
                  ),
                );
              }).toList(),
            );
          });
        },
      ),
    ]);
  }

  static Widget _actionIcon({
    required IconData icon,
    required Color color,
    double size = 16,
    String? tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(icon, size: size, color: color),
        ),
      ),
    );
  }
}