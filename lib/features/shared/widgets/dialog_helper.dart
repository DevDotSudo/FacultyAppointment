import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import 'custom_dialog.dart';

class DialogHelper {
  // ── Change Password Modal ──
  static Future<void> showChangePasswordModal(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isLoading = false;

    return showDialog(
      context: context,
      barrierDismissible: !isLoading,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) => CustomDialog(
            title: 'Change Password',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Password',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(height: 4),
                TextField(
                  controller: currentCtrl,
                  obscureText: obscureCurrent,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderGray)),
                    suffixIcon: IconButton(
                      icon: Icon(obscureCurrent ? Icons.visibility_off : Icons.visibility, size: 20),
                      onPressed: () => setState(() => obscureCurrent = !obscureCurrent),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text('New Password',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(height: 4),
                TextField(
                  controller: newCtrl,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderGray)),
                    suffixIcon: IconButton(
                      icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility, size: 20),
                      onPressed: () => setState(() => obscureNew = !obscureNew),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Confirm New Password',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(height: 4),
                TextField(
                  controller: confirmCtrl,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderGray)),
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility, size: 20),
                      onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () async {
                      if (newCtrl.text.length < 6) {
                        showErrorDialog(context, title: 'Error', message: 'New password must be at least 6 characters');
                        return;
                      }
                      if (newCtrl.text != confirmCtrl.text) {
                        showErrorDialog(context, title: 'Error', message: 'Passwords do not match');
                        return;
                      }
                      setState(() => isLoading = true);
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) throw Exception('Not authenticated');
                        final credential = EmailAuthProvider.credential(
                          email: user.email!,
                          password: currentCtrl.text,
                        );
                        await user.reauthenticateWithCredential(credential);
                        await user.updatePassword(newCtrl.text);

                        currentCtrl.dispose();
                        newCtrl.dispose();
                        confirmCtrl.dispose();

                        if (ctx.mounted) {
                          Navigator.of(ctx).pop();
                        }
                        if (ctx.mounted) {
                          showDialog(
                            context: ctx,
                            builder: (_) => CustomDialog(
                              title: 'Success',
                              actions: [
                                SizedBox(width: double.infinity, child: ElevatedButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text('Done'),
                                )),
                              ],
                              child: Column(mainAxisSize: MainAxisSize.min, children: [
                                const Icon(Icons.check_circle, color: AppColors.success, size: 48),
                                const SizedBox(height: 12),
                                Text('Password changed successfully!',
                                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark), textAlign: TextAlign.center),
                              ]),
                            ),
                          );
                        }
                      } catch (e) {
                        setState(() => isLoading = false);
                        if (ctx.mounted) {
                          showErrorDialog(ctx, title: 'Error', message: e.toString().replaceAll('Exception: ', ''));
                        }
                      }
                    },
                    child: isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Change Password'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Error Dialog ──
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CustomDialog(
        title: title,
        actions: [
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          )),
        ],
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark))),
          ],
        ),
      ),
    );
  }

  // ── Confirm Appointment ──
  static Future<void> showConfirmSubmitModal(
    BuildContext context, {
    required String facultyName,
    required String date,
    required String time,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CustomDialog(
        title: 'Confirm Appointment',
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textMuted))),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: () { Navigator.of(ctx).pop(); onConfirm(); }, child: const Text('Confirm')),
        ],
        child: Text('Are you sure you want to book an appointment with $facultyName on $date at $time?',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark)),
      ),
    );
  }

  // ── Cancel Appointment ──
  static Future<void> showCancelAppointmentModal(
    BuildContext context, {
    required String facultyName,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CustomDialog(
        title: 'Cancel Appointment',
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('No, Keep It', style: GoogleFonts.inter(color: AppColors.textMuted))),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: () { Navigator.of(ctx).pop(); onConfirm(); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger), child: const Text('Yes, Cancel')),
        ],
        child: Text('Are you sure you want to cancel your appointment with $facultyName? This action cannot be undone.',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark)),
      ),
    );
  }

  // ── Accept Request ──
  static Future<void> showAcceptRequestModal(
    BuildContext context, {
    required String studentName,
    required String date,
    required String time,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CustomDialog(
        title: 'Accept Request',
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textMuted))),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: () { Navigator.of(ctx).pop(); onConfirm(); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success), child: const Text('Accept')),
        ],
        child: Text('Are you sure you want to accept the appointment request from $studentName on $date at $time?',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark)),
      ),
    );
  }

  // ── Reject Request ──
  static Future<void> showRejectRequestModal(
    BuildContext context, {
    required String studentName,
    required VoidCallback onConfirm,
  }) {
    final reasonController = TextEditingController();
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CustomDialog(
        title: 'Reject Request',
        actions: [
          TextButton(onPressed: () { reasonController.dispose(); Navigator.of(ctx).pop(); },
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textMuted))),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: () { reasonController.dispose(); Navigator.of(ctx).pop(); onConfirm(); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger), child: const Text('Reject')),
        ],
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Are you sure you want to reject this request from $studentName?',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark)),
          const SizedBox(height: 12),
          Text('Reason (optional)', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 4),
          TextField(controller: reasonController, maxLines: 3,
            decoration: InputDecoration(hintText: 'Enter reason...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderGray)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderGray)))),
        ]),
      ),
    );
  }

  /// Formats a TimeOfDay to a display string like "9:00 AM"
  static String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour == 0 ? 12 : hour}:$minute $period';
  }

  /// Parses a time string like "9:00 AM" back to a TimeOfDay
  static TimeOfDay? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(' ');
      if (parts.length != 2) return null;
      final timeParts = parts[0].split(':');
      if (timeParts.length != 2) return null;
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final period = parts[1];
      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  // ── Add/Edit Schedule with native clock-style time picker ──
  static Future<void> showAddScheduleModal(
    BuildContext context, {
    String? initialDay,
    String? initialStart,
    String? initialEnd,
    required void Function(String day, String startTime, String endTime) onSave,
  }) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    String selectedDay = initialDay ?? 'Monday';
    TimeOfDay selectedStart = _parseTime(initialStart ?? '') ?? const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay selectedEnd = _parseTime(initialEnd ?? '') ?? const TimeOfDay(hour: 12, minute: 0);
    final isEdit = initialDay != null;

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => CustomDialog(
          title: isEdit ? 'Edit Schedule' : 'Add Schedule',
          actions: [
            TextButton(onPressed: () { Navigator.of(ctx).pop(); },
              child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textMuted))),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: () {
              Navigator.of(ctx).pop();
              onSave(selectedDay, _formatTime(selectedStart), _formatTime(selectedEnd));
            },
              child: Text(isEdit ? 'Save Changes' : 'Add')),
          ],
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Align(alignment: Alignment.centerLeft,
              child: Text('Day', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark))),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              initialValue: selectedDay,
              items: days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (v) => setDialogState(() => selectedDay = v ?? selectedDay),
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.borderGray)),
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Start Time', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedStart,
                      helpText: 'Select start time',
                    );
                    if (picked != null) {
                      setDialogState(() => selectedStart = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderGray),
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.fieldFill,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(selectedStart),
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
                        ),
                        const Spacer(),
                        Icon(Icons.edit_calendar_rounded, size: 16, color: AppColors.textHint),
                      ],
                    ),
                  ),
                ),
              ])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('End Time', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedEnd,
                      helpText: 'Select end time',
                    );
                    if (picked != null) {
                      setDialogState(() => selectedEnd = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderGray),
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.fieldFill,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(selectedEnd),
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
                        ),
                        const Spacer(),
                        Icon(Icons.edit_calendar_rounded, size: 16, color: AppColors.textHint),
                      ],
                    ),
                  ),
                ),
              ])),
            ]),
          ]),
        ),
      ),
    );
  }

  // ── Delete Schedule ──
  static Future<void> showDeleteScheduleModal(
    BuildContext context, {
    required String day,
    required String startTime,
    required String endTime,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CustomDialog(
        title: 'Delete Schedule',
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textMuted))),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: () { Navigator.of(ctx).pop(); onConfirm(); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger), child: const Text('Delete')),
        ],
        child: Text('Are you sure you want to delete the $day schedule ($startTime – $endTime)?',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark)),
      ),
    );
  }

  // ── Update Profile Success ──
  static Future<void> showUpdateProfileSuccessModal(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CustomDialog(
        title: 'Profile Updated',
        actions: [SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Done')))],
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 48),
          const SizedBox(height: 12),
          Text('Your profile has been updated successfully.',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted), textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  // ── View Request Detail ──
  static Future<void> showViewRequestModal(
    BuildContext context, {
    required String studentName,
    required String date,
    required String time,
    required String purpose,
    required VoidCallback onAccept,
    required VoidCallback onReject,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CustomDialog(
        title: 'Request Details',
        stackedActions: true,
        actions: [
          ElevatedButton(onPressed: () { Navigator.of(ctx).pop(); onAccept(); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success), child: const Text('Accept')),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: () { Navigator.of(ctx).pop(); onReject(); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger), child: const Text('Reject')),
        ],
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _detailRow('Student', studentName),
          const SizedBox(height: 10),
          _detailRow('Date & Time', '$date · $time'),
          const SizedBox(height: 10),
          _detailRow('Purpose', purpose),
        ]),
      ),
    );
  }

  static Widget _detailRow(String label, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
      const SizedBox(width: 16),
      Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark), textAlign: TextAlign.right)),
    ]);
  }

  // ── Confirm Dialog (generic) ──
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    Color confirmColor = AppColors.primary,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CustomDialog(
        title: title,
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textMuted))),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor), child: Text(confirmLabel)),
        ],
        child: Text(message, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark)),
      ),
    );
  }
}