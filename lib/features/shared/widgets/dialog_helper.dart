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
              stackedActions: true,
              actions: [
                ElevatedButton(
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
                            stackedActions: true,
                            actions: [
                              ElevatedButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
                                child: const Text('Done'),
                              ),
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
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
                  child: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Change Password'),
                ),
              ],
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
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Success Dialog ──
  static Future<void> showSuccessDialog(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onDismiss,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CustomDialog(
        title: title,
        stackedActions: true,
        actions: [
          ElevatedButton(
            onPressed: () { Navigator.of(ctx).pop(); onDismiss?.call(); },
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
            child: const Text('Continue'),
          ),
        ],
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: GoogleFonts.inter(fontSize: 14, color: _textColor(ctx)))),
          ],
        ),
      ),
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
        stackedActions: true,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
            child: const Text('OK'),
          ),
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


  // ── Add/Edit Schedule ──
  static Future<void> showAddScheduleModal(
    BuildContext context, {
    String? initialDay,
    String? initialStart,
    String? initialEnd,
    DateTime? initialDate,
    String? initialConsultationType,
    String? initialLocationOrLink,
    int? initialMaxSlots,
    required void Function(
      String day,
      String startTime,
      String endTime, {
      DateTime? date,
      String consultationType,
      String locationOrLink,
      int maxSlots,
    }) onSave,
  }) {
    final isEdit = initialDay != null;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    if (isMobile) {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        useSafeArea: false,
        backgroundColor: Colors.transparent,
        builder: (_) => DraggableScrollableSheet(
          initialChildSize: 0.95,
          minChildSize: 0.5,
          maxChildSize: 1.0,
          builder: (_, scrollController) => _ScheduleFormSheet(
            isEdit: isEdit,
            initialDay: initialDay,
            initialStart: initialStart,
            initialEnd: initialEnd,
            initialDate: initialDate,
            initialConsultationType: initialConsultationType,
            initialLocationOrLink: initialLocationOrLink,
            initialMaxSlots: initialMaxSlots,
            onSave: onSave,
            scrollController: scrollController,
          ),
        ),
      );
    }

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: _ScheduleFormSheet(
          isEdit: isEdit,
          initialDay: initialDay,
          initialStart: initialStart,
          initialEnd: initialEnd,
          initialDate: initialDate,
          initialConsultationType: initialConsultationType,
          initialLocationOrLink: initialLocationOrLink,
          initialMaxSlots: initialMaxSlots,
          onSave: onSave,
          isDialog: true,
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
        stackedActions: true,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
            child: const Text('Done'),
          ),
        ],
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
    Widget? content,
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
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(message, style: GoogleFonts.inter(fontSize: 14, color: _textColor(ctx))),
          if (content != null) ...[
            const SizedBox(height: 16),
            content,
          ],
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// Schedule Form — scrollable, works as bottom-sheet or dialog
// ═══════════════════════════════════════════════════════
class _ScheduleFormSheet extends StatefulWidget {
  final bool isEdit;
  final bool isDialog;
  final ScrollController? scrollController;
  final String? initialDay;
  final String? initialStart;
  final String? initialEnd;
  final DateTime? initialDate;
  final String? initialConsultationType;
  final String? initialLocationOrLink;
  final int? initialMaxSlots;
  final void Function(
    String day, String startTime, String endTime, {
    DateTime? date, String consultationType,
    String locationOrLink, int maxSlots,
  }) onSave;

  const _ScheduleFormSheet({
    required this.isEdit,
    this.isDialog = false,
    this.scrollController,
    this.initialDay,
    this.initialStart,
    this.initialEnd,
    this.initialDate,
    this.initialConsultationType,
    this.initialLocationOrLink,
    this.initialMaxSlots,
    required this.onSave,
  });

  @override
  State<_ScheduleFormSheet> createState() => _ScheduleFormSheetState();
}

class _ScheduleFormSheetState extends State<_ScheduleFormSheet> {
  static const _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  static const _dayLabels = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  late String _day;
  late TimeOfDay _start;
  late TimeOfDay _end;
  DateTime? _date;
  late String _type;
  late TextEditingController _locCtrl;
  late int _slots;

  @override
  void initState() {
    super.initState();
    _day = widget.initialDay ?? 'Monday';
    _start = _pt(widget.initialStart) ?? const TimeOfDay(hour: 9, minute: 0);
    _end = _pt(widget.initialEnd) ?? const TimeOfDay(hour: 12, minute: 0);
    _date = widget.initialDate;
    _type = widget.initialConsultationType ?? 'face-to-face';
    _locCtrl = TextEditingController(text: widget.initialLocationOrLink ?? '');
    _slots = widget.initialMaxSlots ?? 1;
  }

  @override
  void dispose() { _locCtrl.dispose(); super.dispose(); }

  static TimeOfDay? _pt(String? s) {
    if (s == null || s.isEmpty) return null;
    try {
      final p = s.split(' ');
      if (p.length != 2) return null;
      final tp = p[0].split(':');
      int h = int.parse(tp[0]);
      final m = int.parse(tp[1]);
      if (p[1] == 'PM' && h != 12) h += 12;
      if (p[1] == 'AM' && h == 12) h = 0;
      return TimeOfDay(hour: h, minute: m);
    } catch (_) { return null; }
  }

  static String _ft(TimeOfDay t) {
    final h = t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '${h == 0 ? 12 : h}:$m $p';
  }

  void _save() {
    Navigator.of(context).pop();
    widget.onSave(_day, _ft(_start), _ft(_end),
      date: _date, consultationType: _type,
      locationOrLink: _locCtrl.text.trim(), maxSlots: _slots);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCardBg : Colors.white;
    final tc = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mc = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final bc = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final fc = isDark ? AppColors.darkInputBg : AppColors.lightInputBg;
    final radius = widget.isDialog
        ? const BorderRadius.all(Radius.circular(16))
        : const BorderRadius.vertical(top: Radius.circular(20));

    return Container(
      constraints: widget.isDialog
          ? BoxConstraints(maxWidth: 460, maxHeight: MediaQuery.of(context).size.height * 0.88)
          : const BoxConstraints(),
      decoration: BoxDecoration(color: bg, borderRadius: radius),
      child: Column(children: [
        if (!widget.isDialog)
          Center(child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40, height: 4,
            decoration: BoxDecoration(color: bc, borderRadius: BorderRadius.circular(2)),
          )),
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 10, 0),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(widget.isEdit ? Icons.edit_calendar_rounded : Icons.add_circle_outline_rounded,
                size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(widget.isEdit ? 'Edit Schedule' : 'New Schedule',
              style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.bold, color: tc))),
            IconButton(onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.close_rounded, size: 20, color: mc),
              padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          ]),
        ),
        Divider(color: bc, height: 20),

        // Scrollable body
        _wrapBody(widget.isDialog, ListView(
          shrinkWrap: widget.isDialog,
          controller: widget.scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          children: [
            _lbl('Day of Week', Icons.calendar_view_week_rounded, tc),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(color: fc, borderRadius: BorderRadius.circular(10),
                border: Border.all(color: bc, width: 0.5)),
              child: Row(children: _days.map((d) {
                final sel = _day == d;
                return Expanded(child: GestureDetector(
                  onTap: () => setState(() => _day = d),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(7)),
                    child: Text(d.substring(0, 2), textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 11,
                        fontWeight: sel ? FontWeight.bold : FontWeight.w500,
                        color: sel ? Colors.white : tc)),
                  ),
                ));
              }).toList()),
            ),
            const SizedBox(height: 14),

            _lbl('Date & Time', Icons.schedule_rounded, tc),
            const SizedBox(height: 6),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(context: context,
                  initialDate: _date ?? DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)));
                if (d != null) setState(() => _date = d);
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                decoration: BoxDecoration(color: fc, borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _date != null ? AppColors.primary.withValues(alpha: 0.5) : bc)),
                child: Row(children: [
                  Icon(Icons.event_rounded, size: 16, color: _date != null ? AppColors.primary : mc),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    _date != null ? '${_dayLabels[_date!.weekday - 1]}, ${_date!.day}/${_date!.month}/${_date!.year}' : 'Select date (optional)',
                    style: GoogleFonts.inter(fontSize: 13, color: _date != null ? tc : mc,
                      fontWeight: _date != null ? FontWeight.w600 : FontWeight.w400))),
                  if (_date != null) GestureDetector(
                    onTap: () => setState(() => _date = null),
                    child: Icon(Icons.close_rounded, size: 15, color: mc)),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _tc('Start', _start, fc, bc, tc, mc, () async {
                final t = await showTimePicker(context: context, initialTime: _start);
                if (t != null) setState(() => _start = t);
              })),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.arrow_forward_rounded, size: 14, color: mc)),
              Expanded(child: _tc('End', _end, fc, bc, tc, mc, () async {
                final t = await showTimePicker(context: context, initialTime: _end);
                if (t != null) setState(() => _end = t);
              })),
            ]),
            const SizedBox(height: 14),

            _lbl('Type', Icons.groups_rounded, tc),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(color: fc, borderRadius: BorderRadius.circular(10),
                border: Border.all(color: bc, width: 0.5)),
              child: Row(children: [
                _tp('face-to-face', 'Face-to-face', Icons.location_on_rounded, AppColors.success, tc, mc),
                const SizedBox(width: 3),
                _tp('online', 'Online', Icons.videocam_rounded, AppColors.primary, tc, mc),
              ]),
            ),
            const SizedBox(height: 14),

            _lbl(_type == 'online' ? 'Meeting Link' : 'Location',
              _type == 'online' ? Icons.link_rounded : Icons.place_rounded, tc),
            const SizedBox(height: 6),
            TextField(
              controller: _locCtrl,
              style: GoogleFonts.inter(fontSize: 13, color: tc),
              decoration: InputDecoration(
                hintText: _type == 'online' ? 'https://meet.google.com/...' : 'Room 301, Building A',
                hintStyle: GoogleFonts.inter(fontSize: 13, color: mc),
                filled: true, fillColor: fc, isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: bc)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: bc)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
              ),
            ),
            const SizedBox(height: 14),

            _lbl('Max Students', Icons.people_alt_rounded, tc),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: fc, borderRadius: BorderRadius.circular(10),
                border: Border.all(color: bc)),
              child: Row(children: [
                Flexible(child: Text('$_slots student${_slots > 1 ? 's' : ''}',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: tc),
                  overflow: TextOverflow.ellipsis)),
                const Spacer(),
                _cb(Icons.remove_rounded, _slots > 1, () => setState(() => _slots--), mc),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('$_slots', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: tc))),
                _cb(Icons.add_rounded, _slots < 50, () => setState(() => _slots++), mc),
              ]),
            ),
            const SizedBox(height: 20),
            // Inline button for mobile (no gap)
            if (!widget.isDialog) ...[
              SafeArea(top: false, child: SizedBox(
                width: double.infinity, height: 44,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: Icon(widget.isEdit ? Icons.check_rounded : Icons.add_rounded, size: 18),
                  label: Text(widget.isEdit ? 'Save Changes' : 'Add Schedule',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0),
                ),
              )),
              const SizedBox(height: 16),
            ],
          ],
        )),

        // Fixed footer for desktop dialog only
        if (widget.isDialog)
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
            decoration: BoxDecoration(color: bg,
              border: Border(top: BorderSide(color: bc, width: 0.5))),
            child: SizedBox(
              width: double.infinity, height: 44,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: Icon(widget.isEdit ? Icons.check_rounded : Icons.add_rounded, size: 18),
                label: Text(widget.isEdit ? 'Save Changes' : 'Add Schedule',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0),
              ),
            ),
          ),
      ]),
    );
  }


  Widget _wrapBody(bool isDialog, Widget child) =>
    isDialog ? Flexible(child: child) : Expanded(child: child);

  Widget _lbl(String t, IconData i, Color c) => Row(children: [
    Icon(i, size: 14, color: AppColors.primary), const SizedBox(width: 6),
    Text(t, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: c)),
  ]);

  Widget _tc(String l, TimeOfDay t, Color f, Color b, Color tc, Color mc, VoidCallback tap) =>
    InkWell(onTap: tap, borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(color: f, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: b)),
        child: Row(children: [
          Icon(Icons.access_time_rounded, size: 15, color: AppColors.primary),
          const SizedBox(width: 6),
          Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l, style: GoogleFonts.inter(fontSize: 10, color: mc, fontWeight: FontWeight.w500)),
            Text(_ft(t), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: tc),
              overflow: TextOverflow.ellipsis),
          ])),
        ]),
      ));

  Widget _tp(String v, String l, IconData i, Color ac, Color tc, Color mc) {
    final s = _type == v;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _type = v),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(color: s ? ac : Colors.transparent,
          borderRadius: BorderRadius.circular(7)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(i, size: 14, color: s ? Colors.white : mc),
          const SizedBox(width: 4),
          Text(l, style: GoogleFonts.inter(fontSize: 12,
            fontWeight: s ? FontWeight.bold : FontWeight.w500,
            color: s ? Colors.white : tc)),
        ]),
      ),
    ));
  }

  Widget _cb(IconData i, bool e, VoidCallback tap, Color mc) => GestureDetector(
    onTap: e ? tap : null,
    child: Container(width: 30, height: 30,
      decoration: BoxDecoration(
        color: e ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: e ? AppColors.primary.withValues(alpha: 0.3) : mc.withValues(alpha: 0.3))),
      child: Icon(i, size: 16, color: e ? AppColors.primary : mc.withValues(alpha: 0.4)),
    ),
  );
}