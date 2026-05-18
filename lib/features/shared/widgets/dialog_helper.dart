import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import 'custom_dialog.dart';

class DialogHelper {
  /// Get theme-aware text color
  static Color _textColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  }

  /// Get theme-aware muted color
  static Color _mutedColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  }

  /// Get theme-aware border color
  static Color _borderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkBorder : AppColors.lightBorder;
  }

  /// Get theme-aware fill color
  static Color _fillColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkInputBg : AppColors.lightInputBg;
  }

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
          builder: (context, setState) {
            final textColor = _textColor(context);
            final mutedColor = _mutedColor(context);
            final borderColor = _borderColor(context);
            final fillColor = _fillColor(context);
            final inputBorder = OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            );

            return CustomDialog(
              title: 'Change Password',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Password',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: currentCtrl,
                    obscureText: obscureCurrent,
                    decoration: InputDecoration(
                      border: inputBorder,
                      enabledBorder: inputBorder,
                      fillColor: fillColor,
                      filled: true,
                      suffixIcon: IconButton(
                        icon: Icon(obscureCurrent ? Icons.visibility_off : Icons.visibility, size: 20, color: mutedColor),
                        onPressed: () => setState(() => obscureCurrent = !obscureCurrent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('New Password',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: newCtrl,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      border: inputBorder,
                      enabledBorder: inputBorder,
                      fillColor: fillColor,
                      filled: true,
                      suffixIcon: IconButton(
                        icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility, size: 20, color: mutedColor),
                        onPressed: () => setState(() => obscureNew = !obscureNew),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Confirm New Password',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: confirmCtrl,
                    obscureText: obscureConfirm,
                    decoration: InputDecoration(
                      border: inputBorder,
                      enabledBorder: inputBorder,
                      fillColor: fillColor,
                      filled: true,
                      suffixIcon: IconButton(
                        icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility, size: 20, color: mutedColor),
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

                          if (ctx.mounted) Navigator.of(ctx).pop();
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
                                    style: GoogleFonts.inter(fontSize: 14, color: textColor), textAlign: TextAlign.center),
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
            );
          },
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
            Expanded(child: Text(message, style: GoogleFonts.inter(fontSize: 14, color: _textColor(ctx)))),
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
          TextButton(onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: GoogleFonts.inter(color: _mutedColor(ctx)))),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: () { Navigator.of(ctx).pop(); onConfirm(); }, child: const Text('Confirm')),
        ],
        child: Text('Are you sure you want to book an appointment with $facultyName on $date at $time?',
          style: GoogleFonts.inter(fontSize: 14, color: _textColor(ctx))),
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
          TextButton(onPressed: () => Navigator.of(ctx).pop(),
            child: Text('No, Keep It', style: GoogleFonts.inter(color: _mutedColor(ctx)))),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: () { Navigator.of(ctx).pop(); onConfirm(); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger), child: const Text('Yes, Cancel')),
        ],
        child: Text('Are you sure you want to cancel your appointment with $facultyName? This action cannot be undone.',
          style: GoogleFonts.inter(fontSize: 14, color: _textColor(ctx))),
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
          TextButton(onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: GoogleFonts.inter(color: _mutedColor(ctx)))),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: () { Navigator.of(ctx).pop(); onConfirm(); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success), child: const Text('Accept')),
        ],
        child: Text('Are you sure you want to accept the appointment request from $studentName on $date at $time?',
          style: GoogleFonts.inter(fontSize: 14, color: _textColor(ctx))),
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
      builder: (ctx) {
        final textColor = _textColor(ctx);
        final mutedColor = _mutedColor(ctx);
        final borderColor = _borderColor(ctx);
        final fillColor = _fillColor(ctx);
        final inputBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor),
        );

        return CustomDialog(
          title: 'Reject Request',
          actions: [
            TextButton(onPressed: () { reasonController.dispose(); Navigator.of(ctx).pop(); },
              child: Text('Cancel', style: GoogleFonts.inter(color: mutedColor))),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: () { reasonController.dispose(); Navigator.of(ctx).pop(); onConfirm(); },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger), child: const Text('Reject')),
          ],
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Are you sure you want to reject this request from $studentName?',
              style: GoogleFonts.inter(fontSize: 14, color: textColor)),
            const SizedBox(height: 12),
            Text('Reason (optional)', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
            const SizedBox(height: 4),
            TextField(controller: reasonController, maxLines: 3,
              style: GoogleFonts.inter(color: textColor),
              decoration: InputDecoration(
                hintText: 'Enter reason...',
                hintStyle: GoogleFonts.inter(color: mutedColor),
                border: inputBorder,
                enabledBorder: inputBorder,
                fillColor: fillColor,
                filled: true,
              )),
          ]),
        );
      },
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
        builder: (context, setDialogState) {
          final textColor = _textColor(context);
          final mutedColor = _mutedColor(context);
          final borderColor = _borderColor(context);
          final fillColor = _fillColor(context);
          final inputBorder = OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: borderColor),
          );

          return CustomDialog(
            title: isEdit ? 'Edit Schedule' : 'Add Schedule',
            actions: [
              TextButton(onPressed: () { Navigator.of(ctx).pop(); },
                child: Text('Cancel', style: GoogleFonts.inter(color: mutedColor))),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: () {
                Navigator.of(ctx).pop();
                onSave(selectedDay, _formatTime(selectedStart), _formatTime(selectedEnd));
              },
                child: Text(isEdit ? 'Save Changes' : 'Add')),
            ],
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Align(alignment: Alignment.centerLeft,
                child: Text('Day', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: textColor))),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                initialValue: selectedDay,
                items: days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) => setDialogState(() => selectedDay = v ?? selectedDay),
                decoration: InputDecoration(
                  border: inputBorder,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              // Day selector
              Text('Day of the Week', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: days.map((day) {
                    final isSelected = selectedDay == day;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setDialogState(() => selectedDay = day),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            day.substring(0, 3),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : textColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Start Time', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedStart,
                        helpText: 'Select start time',
                      );
                      if (picked != null) setDialogState(() => selectedStart = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(12),
                        color: fillColor,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 20, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Text(
                            _formatTime(selectedStart),
                            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
                          ),
                          const Spacer(),
                          Icon(Icons.edit_calendar_rounded, size: 20, color: mutedColor),
                        ],
                      ),
                    ),
                  ),
                ])),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('End Time', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedEnd,
                        helpText: 'Select end time',
                      );
                      if (picked != null) setDialogState(() => selectedEnd = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(12),
                        color: fillColor,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 20, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Text(
                            _formatTime(selectedEnd),
                            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
                          ),
                          const Spacer(),
                          Icon(Icons.edit_calendar_rounded, size: 20, color: mutedColor),
                        ],
                      ),
                    ),
                  ),
                ])),
              ]),
            ]),
          );
        },
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
          TextButton(onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: GoogleFonts.inter(color: _mutedColor(ctx)))),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: () { Navigator.of(ctx).pop(); onConfirm(); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger), child: const Text('Delete')),
        ],
        child: Text('Are you sure you want to delete the $day schedule ($startTime – $endTime)?',
          style: GoogleFonts.inter(fontSize: 14, color: _textColor(ctx))),
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
            style: GoogleFonts.inter(fontSize: 14, color: _mutedColor(ctx)), textAlign: TextAlign.center),
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
          _detailRow(ctx, 'Student', studentName),
          const SizedBox(height: 10),
          _detailRow(ctx, 'Date & Time', '$date · $time'),
          const SizedBox(height: 10),
          _detailRow(ctx, 'Purpose', purpose),
        ]),
      ),
    );
  }

  static Widget _detailRow(BuildContext context, String label, String value) {
    final textColor = _textColor(context);
    final mutedColor = _mutedColor(context);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: mutedColor)),
      const SizedBox(width: 16),
      Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 14, color: textColor), textAlign: TextAlign.right)),
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
          TextButton(onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: GoogleFonts.inter(color: _mutedColor(ctx)))),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor), child: Text(confirmLabel)),
        ],
        child: Text(message, style: GoogleFonts.inter(fontSize: 14, color: _textColor(ctx))),
      ),
    );
  }
}