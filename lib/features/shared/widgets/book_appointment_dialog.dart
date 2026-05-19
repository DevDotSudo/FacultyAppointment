import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

/// Responsive book appointment dialog
/// Mobile: Full-screen page
/// Desktop: Centered dialog
class BookAppointmentDialog {
  static Future<bool?> show(
    BuildContext context, {
    required String facultyId,
    required String facultyName,
  }) {
    final width = MediaQuery.of(context).size.width;
    
    if (Responsive.isMobile(width)) {
      // Mobile: Full-screen page
      return Navigator.of(context, rootNavigator: true).push<bool>(
        MaterialPageRoute(
          builder: (_) => _BookAppointmentPage(
            facultyId: facultyId,
            facultyName: facultyName,
          ),
          fullscreenDialog: true,
        ),
      );
    }
    
    // Desktop: Dialog
    return showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        child: _BookAppointmentContent(
          facultyId: facultyId,
          facultyName: facultyName,
        ),
      ),
    );
  }
}

/// Full-screen page for mobile
class _BookAppointmentPage extends StatelessWidget {
  final String facultyId;
  final String facultyName;

  const _BookAppointmentPage({
    required this.facultyId,
    required this.facultyName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkCard : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(
          'Book Appointment',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: _BookAppointmentContent(
        facultyId: facultyId,
        facultyName: facultyName,
      ),
    );
  }
}

/// Shared content for both mobile and desktop
class _BookAppointmentContent extends StatefulWidget {
  final String facultyId;
  final String facultyName;

  const _BookAppointmentContent({
    required this.facultyId,
    required this.facultyName,
  });

  @override
  State<_BookAppointmentContent> createState() => _BookAppointmentContentState();
}

class _BookAppointmentContentState extends State<_BookAppointmentContent> {
  final _purposeCtrl = TextEditingController();
  List<Map<String, dynamic>> _schedules = [];
  String? _selectedScheduleId;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  @override
  void dispose() {
    _purposeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSchedules() async {
    try {
      final now = DateTime.now();
      final snap = await FirebaseFirestore.instance
          .collection('faculty_availability')
          .where('faculty_id', isEqualTo: widget.facultyId)
          .where('is_active', isEqualTo: true)
          .get();

      final available = <Map<String, dynamic>>[];
      for (final doc in snap.docs) {
        final d = doc.data();
        final max = (d['max_slots'] as num?)?.toInt() ?? 1;
        final booked = (d['booked_slots'] as num?)?.toInt() ?? 0;
        if (booked >= max) continue;
        
        final rawDate = d['date'];
        if (rawDate is Timestamp) {
          if (rawDate.toDate().isBefore(DateTime(now.year, now.month, now.day))) {
            continue;
          }
        }
        available.add({'id': doc.id, ...d});
      }

      if (mounted) {
        setState(() {
          _schedules = available;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (_selectedScheduleId == null) {
      _showError('Please select a time slot');
      return;
    }
    if (_purposeCtrl.text.trim().isEmpty) {
      _showError('Please enter a purpose');
      return;
    }

    setState(() => _submitting = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final studentSnap = await FirebaseFirestore.instance
          .collection('students')
          .doc(uid)
          .get();
      final studentName = studentSnap.data()?['full_name'] as String? ?? 'Student';

      final schedule = _schedules.firstWhere((s) => s['id'] == _selectedScheduleId);
      final rawDate = schedule['date'];
      final dateStr = rawDate is Timestamp
          ? DateFormat('EEE, MMM d, yyyy').format(rawDate.toDate())
          : (schedule['day'] as String? ?? '');
      final timeStr = '${schedule['start_time']} – ${schedule['end_time']}';

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final slotRef = FirebaseFirestore.instance
            .collection('faculty_availability')
            .doc(_selectedScheduleId!);
        final slotDoc = await transaction.get(slotRef);

        if (!slotDoc.exists) {
          throw Exception('Schedule slot no longer available');
        }

        final slotData = slotDoc.data()!;
        final max = (slotData['max_slots'] as num?)?.toInt() ?? 1;
        final booked = (slotData['booked_slots'] as num?)?.toInt() ?? 0;

        if (booked >= max) {
          throw Exception('This slot is now fully booked');
        }

        transaction.update(slotRef, {'booked_slots': FieldValue.increment(1)});

        final requestRef = FirebaseFirestore.instance
            .collection('appointment_requests')
            .doc();
        transaction.set(requestRef, {
          'student_id': uid,
          'student_name': studentName,
          'faculty_id': widget.facultyId,
          'faculty_name': widget.facultyName,
          'faculty_initials': widget.facultyName
              .split(' ')
              .map((e) => e.isNotEmpty ? e[0] : '')
              .take(2)
              .join()
              .toUpperCase(),
          'date': dateStr,
          'time': timeStr,
          'purpose': _purposeCtrl.text.trim(),
          'schedule_id': _selectedScheduleId,
          'status': 'pending',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      });

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        _showError(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final fillColor = isDark ? AppColors.darkInputBg : AppColors.lightInputBg;

    final isMobile = Responsive.isMobile(width);
    final padding = Responsive.outerPadding(width);

    Widget content = ListView(
      padding: padding,
      children: [
        // Available Slots Section
        Text(
          'Available Slots',
          style: GoogleFonts.inter(
            fontSize: Responsive.h4(width).fontSize,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        SizedBox(height: Responsive.s12),

        if (_loading)
          ...List.generate(
            3,
            (_) => Container(
              height: 80,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(Responsive.cardRadius(width)),
              ),
            ),
          )
        else if (_schedules.isEmpty)
          Container(
            padding: EdgeInsets.all(Responsive.s16),
            decoration: BoxDecoration(
              color: AppColors.statusPending.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Responsive.cardRadius(width)),
              border: Border.all(
                color: AppColors.statusPending.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: AppColors.statusPending,
                ),
                SizedBox(width: Responsive.s12),
                Expanded(
                  child: Text(
                    'No available slots for this faculty',
                    style: GoogleFonts.inter(
                      fontSize: Responsive.body(width).fontSize,
                      color: AppColors.statusPending,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ..._schedules.map((schedule) => _buildScheduleCard(
                schedule,
                width,
                isDark,
                textColor,
                mutedColor,
                borderColor,
                fillColor,
              )),

        SizedBox(height: Responsive.s24),

        // Purpose Section
        Text(
          'Purpose',
          style: GoogleFonts.inter(
            fontSize: Responsive.h4(width).fontSize,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        SizedBox(height: Responsive.s8),
        TextField(
          controller: _purposeCtrl,
          maxLines: 3,
          style: GoogleFonts.inter(
            fontSize: Responsive.body(width).fontSize,
            color: textColor,
          ),
          decoration: InputDecoration(
            hintText: 'Describe the purpose of your appointment...',
            hintStyle: GoogleFonts.inter(
              fontSize: Responsive.body(width).fontSize,
              color: mutedColor,
            ),
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Responsive.inputRadius(width)),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Responsive.inputRadius(width)),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Responsive.inputRadius(width)),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: EdgeInsets.all(Responsive.s12),
          ),
        ),
        SizedBox(height: Responsive.s24),

        // Action Buttons
        if (isMobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: (_submitting || _schedules.isEmpty) ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, Responsive.buttonHeight(width)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Responsive.inputRadius(width)),
                  ),
                  elevation: 0,
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Confirm Booking',
                        style: GoogleFonts.inter(
                          fontSize: Responsive.button(width).fontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(color: mutedColor),
                ),
              ),
              SizedBox(width: Responsive.s12),
              ElevatedButton(
                onPressed: (_submitting || _schedules.isEmpty) ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.s24,
                    vertical: Responsive.s12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Responsive.inputRadius(width)),
                  ),
                  elevation: 0,
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Confirm',
                        style: GoogleFonts.inter(
                          fontSize: Responsive.button(width).fontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
      ],
    );

    // For desktop, wrap in constrained container
    if (!isMobile) {
      content = Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(Responsive.s20),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(Responsive.s8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: Responsive.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Book Appointment',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        Text(
                          widget.facultyName,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: mutedColor),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: borderColor),
            Expanded(child: content),
          ],
        ),
      );
    }

    return content;
  }

  Widget _buildScheduleCard(
    Map<String, dynamic> schedule,
    double width,
    bool isDark,
    Color textColor,
    Color mutedColor,
    Color borderColor,
    Color fillColor,
  ) {
    final id = schedule['id'] as String;
    final isSelected = _selectedScheduleId == id;
    final max = (schedule['max_slots'] as num?)?.toInt() ?? 1;
    final booked = (schedule['booked_slots'] as num?)?.toInt() ?? 0;
    final remaining = max - booked;
    final rawDate = schedule['date'];
    final dateStr = rawDate is Timestamp
        ? DateFormat('EEE, MMM d, yyyy').format(rawDate.toDate())
        : (schedule['day'] as String? ?? '');
    final isOnline = (schedule['consultation_type'] as String? ?? '') == 'online';

    return GestureDetector(
      onTap: () => setState(() => _selectedScheduleId = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(Responsive.s12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08)
              : fillColor,
          border: Border.all(
            color: isSelected ? AppColors.primary : borderColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(Responsive.cardRadius(width)),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : borderColor,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            SizedBox(width: Responsive.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateStr,
                    style: GoogleFonts.inter(
                      fontSize: Responsive.body(width).fontSize,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: Responsive.s4),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 14, color: mutedColor),
                      SizedBox(width: Responsive.s4),
                      Text(
                        '${schedule['start_time']} – ${schedule['end_time']}',
                        style: GoogleFonts.inter(
                          fontSize: Responsive.small(width).fontSize,
                          color: mutedColor,
                        ),
                      ),
                      SizedBox(width: Responsive.s8),
                      Icon(
                        isOnline
                            ? Icons.videocam_rounded
                            : Icons.location_on_rounded,
                        size: 14,
                        color: isOnline ? AppColors.primary : AppColors.success,
                      ),
                      SizedBox(width: Responsive.s4),
                      Text(
                        isOnline ? 'Online' : 'In-person',
                        style: GoogleFonts.inter(
                          fontSize: Responsive.small(width).fontSize,
                          color:
                              isOnline ? AppColors.primary : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.s8,
                vertical: Responsive.s4,
              ),
              decoration: BoxDecoration(
                color: (remaining <= 2
                        ? AppColors.statusPending
                        : AppColors.statusAccepted)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$remaining left',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: remaining <= 2
                      ? AppColors.statusPending
                      : AppColors.statusAccepted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
