import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import 'custom_dialog.dart';

class DialogHelper {
  // ── Confirm Appointment (Student: Book Appointment) ──
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
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppColors.textMuted)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
        child: Text(
          'Are you sure you want to book an appointment with $facultyName on $date at $time?',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
        ),
      ),
    );
  }

  // ── Cancel Appointment (Student: My Appointments) ──
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
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('No, Keep It',
                style: GoogleFonts.inter(color: AppColors.textMuted)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusRejected,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
        child: Text(
          'Are you sure you want to cancel your appointment with $facultyName? This action cannot be undone.',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
        ),
      ),
    );
  }

  // ── Accept Request (Faculty: Request Detail) ──
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
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppColors.textMuted)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.statusAccepted),
            child: const Text('Accept'),
          ),
        ],
        child: Text(
          'Are you sure you want to accept the appointment request from $studentName on $date at $time?',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
        ),
      ),
    );
  }

  // ── Reject Request (Faculty: Request Detail) ──
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
          TextButton(
            onPressed: () {
              reasonController.dispose();
              Navigator.of(ctx).pop();
            },
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppColors.textMuted)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              reasonController.dispose();
              Navigator.of(ctx).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusRejected,
            ),
            child: const Text('Reject'),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to reject this request from $studentName?',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
            ),
            const SizedBox(height: 12),
            Text(
              'Reason (optional)',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.borderGray),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.borderGray),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Add/Edit Schedule (Faculty: Manage Availability) ──
  static Future<void> showAddScheduleModal(
    BuildContext context, {
    String? initialDay,
    String? initialStart,
    String? initialEnd,
    required VoidCallback onSave,
  }) {
    final dayController = TextEditingController(text: initialDay ?? '');
    final startController = TextEditingController(text: initialStart ?? '');
    final endController = TextEditingController(text: initialEnd ?? '');
    final isEdit = initialDay != null;

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CustomDialog(
        title: isEdit ? 'Edit Schedule' : 'Add Schedule',
        actions: [
          TextButton(
            onPressed: () {
              dayController.dispose();
              startController.dispose();
              endController.dispose();
              Navigator.of(ctx).pop();
            },
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppColors.textMuted)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              dayController.dispose();
              startController.dispose();
              endController.dispose();
              Navigator.of(ctx).pop();
              onSave();
            },
            child: Text(isEdit ? 'Save Changes' : 'Add'),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Day
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Day',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark),
              ),
            ),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              initialValue: initialDay ?? 'Monday',
              items: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => dayController.text = v ?? '',
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.borderGray),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            // Start & End time row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Time',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: startController,
                        decoration: InputDecoration(
                          hintText: 'e.g. 9:00 AM',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide:
                                const BorderSide(color: AppColors.borderGray),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'End Time',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: endController,
                        decoration: InputDecoration(
                          hintText: 'e.g. 12:00 PM',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide:
                                const BorderSide(color: AppColors.borderGray),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Delete Schedule (Faculty: Manage Availability) ──
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
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppColors.textMuted)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusRejected,
            ),
            child: const Text('Delete'),
          ),
        ],
        child: Text(
          'Are you sure you want to delete the $day schedule ($startTime – $endTime)?',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
        ),
      ),
    );
  }

  // ── Update Profile Success (Both) ──
  static Future<void> showUpdateProfileSuccessModal(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CustomDialog(
        title: 'Profile Updated',
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Done'),
            ),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle,
                color: AppColors.statusAccepted, size: 48),
            const SizedBox(height: 12),
            Text(
              'Your profile has been updated successfully.',
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── View Request Detail (Faculty: Shows full details as modal) ──
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
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onAccept();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusAccepted,
            ),
            child: const Text('Accept'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onReject();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusRejected,
            ),
            child: const Text('Reject'),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Student', studentName),
            const SizedBox(height: 10),
            _detailRow('Date & Time', '$date · $time'),
            const SizedBox(height: 10),
            _detailRow('Purpose', purpose),
          ],
        ),
      ),
    );
  }

  static Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(value, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark), textAlign: TextAlign.right),
        ),
      ],
    );
  }

  // ── Confirm Dialog (generic) ──
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    Color confirmColor = AppColors.primaryBlue,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CustomDialog(
        title: title,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child:
                Text('Cancel', style: GoogleFonts.inter(color: AppColors.textMuted)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            child: Text(confirmLabel),
          ),
        ],
        child: Text(
          message,
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
        ),
      ),
    );
  }
}