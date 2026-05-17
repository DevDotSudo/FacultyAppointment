import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/student/domain/usecases/book_appointment_usecase.dart';

/// Full dialog-based appointment booking system
/// Students can select faculty, date, and see only available times
class BookAppointmentDialog {
  static Future<void> show(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkCard : Colors.white;
    final textColor = isDark ? AppColors.darkText : AppColors.textDark;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.textMuted;

    String? selectedFacultyId;
    String? selectedFacultyName;
    DateTime? selectedDate;
    String? selectedTime;
    bool isSubmitting = false;
    final purposeCtrl = TextEditingController();
    final bookUseCase = BookAppointmentUseCase();

    // Available times from faculty schedule
    final availableTimes = <String>[];

    Future<void> loadTimes(String facultyId, DateTime? date) async {
      availableTimes.clear();
      if (date == null) return;

      final dayName = _dayIndexToName(date.weekday);
      try {
        final snap = await FirebaseFirestore.instance
            .collection('faculty_availability')
            .where('faculty_id', isEqualTo: facultyId)
            .get();

        if (snap.docs.isEmpty) {
          // No schedule set - show a message
          return;
        }

        for (final doc in snap.docs) {
          final d = doc.data();
          final day = d['day'] as String? ?? '';
          final start = d['start_time'] as String? ?? '';
          final end = d['end_time'] as String? ?? '';

          if (day.toLowerCase() == dayName.toLowerCase()) {
            // Parse start and end times to generate slots
            final parsed =
                _parseTimeRange(start, end);
            if (parsed != null) {
              availableTimes.addAll(parsed);
            }
          }
        }
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> onFacultyChanged(String? id, String? name) async {
              selectedFacultyId = id;
              selectedFacultyName = name;
              selectedDate = null;
              selectedTime = null;
              availableTimes.clear();
              setDialogState(() {});
            }

            Future<void> onDateSelected(DateTime date) async {
              selectedDate = date;
              selectedTime = null;
              await loadTimes(selectedFacultyId!, date);
              setDialogState(() {});
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkMuted : AppColors.borderGray,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Book Appointment',
                          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => Navigator.of(ctx).pop(),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkBg : AppColors.fieldFill,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.close_rounded, size: 22, color: AppColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Step 1: Select Faculty
                          _stepLabel('1', 'Select Faculty', isDark),
                          const SizedBox(height: 8),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('faculty').snapshots(),
                            builder: (context, snap) {
                              final list = snap.hasData
                                  ? snap.data!.docs.map((d) => {
                                        'id': d.id,
                                        'name': (d.data() as Map)['full_name'] as String? ?? 'Unknown',
                                        'dept': (d.data() as Map)['department'] as String? ?? '',
                                      }).toList()
                                  : <Map<String, String>>[];
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.borderGray),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: list.map((f) {
                                    final isSelected = selectedFacultyId == f['id'];
                                    return InkWell(
                                      onTap: () => onFacultyChanged(f['id'], f['name']),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : null,
                                          border: Border(
                                            bottom: BorderSide(
                                              color: isDark ? AppColors.darkBorder : AppColors.borderGray,
                                              width: 0.5,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 44, height: 44,
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF8B5CF6)]),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  (f['name'] ?? 'F').split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase(),
                                                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    f['name'] ?? '',
                                                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
                                                  ),
                                                  if ((f['dept'] ?? '').isNotEmpty)
                                                    Text(
                                                      f['dept'] ?? '',
                                                      style: GoogleFonts.inter(fontSize: 12, color: mutedColor),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            if (isSelected)
                                              Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary,
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // Step 2: Select Date
                          if (selectedFacultyId != null) ...[
                            _stepLabel('2', 'Select Date', isDark),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now().add(const Duration(days: 1)),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 90)),
                                  helpText: 'Select appointment date',
                                  builder: (context, child) => Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: AppColors.primary,
                                        onPrimary: Colors.white,
                                      ),
                                    ),
                                    child: child!,
                                  ),
                                );
                                if (picked != null) {
                                  await onDateSelected(picked);
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.borderGray),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today_rounded, size: 22, color: AppColors.primary),
                                    const SizedBox(width: 12),
                                    Text(
                                      selectedDate != null
                                          ? '${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}'
                                          : 'Pick a date',
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: selectedDate != null ? textColor : mutedColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Step 3: Select Time
                          if (selectedDate != null) ...[
                            _stepLabel('3', 'Select Time', isDark),
                            const SizedBox(height: 8),
                            if (availableTimes.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'No available time slots for this day. Try a different date.',
                                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textDark),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: availableTimes.map((time) {
                                  final isSelected = selectedTime == time;
                                  return InkWell(
                                    onTap: () => setDialogState(() => selectedTime = time),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBg : AppColors.fieldFill),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.borderGray),
                                        ),
                                      ),
                                      child: Text(
                                        time,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          color: isSelected ? Colors.white : textColor,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            const SizedBox(height: 24),
                          ],

                          // Step 4: Purpose
                          if (selectedTime != null) ...[
                            _stepLabel('4', 'Purpose', isDark),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: purposeCtrl,
                              maxLines: 3,
                              style: GoogleFonts.inter(fontSize: 14, color: textColor),
                              decoration: InputDecoration(
                                hintText: 'Describe the purpose of your appointment...',
                                hintStyle: GoogleFonts.inter(fontSize: 14, color: mutedColor),
                                filled: true,
                                fillColor: isDark ? AppColors.darkBg : AppColors.fieldFill,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderGray),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.borderGray),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Submit button
                          if (selectedFacultyId != null && selectedDate != null && selectedTime != null) ...[
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: isSubmitting
                                    ? null
                                    : () async {
                                        if (purposeCtrl.text.trim().isEmpty) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Please enter a purpose'), backgroundColor: AppColors.danger),
                                            );
                                          }
                                          return;
                                        }
                                        setDialogState(() => isSubmitting = true);
                                        try {
                                          final studentSnap = await FirebaseFirestore.instance
                                              .collection('students')
                                              .doc(uid)
                                              .get();
                                          final studentName = studentSnap.get('full_name') as String? ?? 'Student';
                                          final dateStr =
                                              '${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}';

                                          await bookUseCase.call(
                                            studentId: uid,
                                            studentName: studentName,
                                            facultyId: selectedFacultyId!,
                                            facultyName: selectedFacultyName ?? 'Faculty',
                                            facultyInitials: (selectedFacultyName ?? 'F')
                                                .split(' ')
                                                .map((e) => e.isNotEmpty ? e[0] : '')
                                                .take(2)
                                                .join()
                                                .toUpperCase(),
                                            date: dateStr,
                                            time: selectedTime!,
                                            purpose: purposeCtrl.text.trim(),
                                          );

                                          purposeCtrl.dispose();
                                          if (context.mounted) {
                                            Navigator.of(ctx).pop();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Appointment submitted! ✓'),
                                                backgroundColor: AppColors.success,
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}'), backgroundColor: AppColors.danger),
                                            );
                                          }
                                        } finally {
                                          if (context.mounted) setDialogState(() => isSubmitting = false);
                                        }
                                      },
                                icon: isSubmitting
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                    : const Icon(Icons.send_rounded, size: 20),
                                label: Text(
                                  isSubmitting ? 'Submitting...' : 'Submit Appointment',
                                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ],
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

  static Widget _stepLabel(String number, String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 26, height: 26,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF8B5CF6)]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.textDark,
          ),
        ),
      ],
    );
  }

  static String _dayIndexToName(int index) {
    switch (index) {
      case DateTime.monday: return 'Monday';
      case DateTime.tuesday: return 'Tuesday';
      case DateTime.wednesday: return 'Wednesday';
      case DateTime.thursday: return 'Thursday';
      case DateTime.friday: return 'Friday';
      case DateTime.saturday: return 'Saturday';
      case DateTime.sunday: return 'Sunday';
      default: return '';
    }
  }

  static List<String>? _parseTimeRange(String start, String end) {
    const allTimes = [
      '7:00 AM', '7:30 AM', '8:00 AM', '8:30 AM',
      '9:00 AM', '9:30 AM', '10:00 AM', '10:30 AM',
      '11:00 AM', '11:30 AM', '12:00 PM', '12:30 PM',
      '1:00 PM', '1:30 PM', '2:00 PM', '2:30 PM',
      '3:00 PM', '3:30 PM', '4:00 PM', '4:30 PM',
      '5:00 PM', '5:30 PM', '6:00 PM',
    ];
    final startIdx = allTimes.indexOf(start);
    final endIdx = allTimes.indexOf(end);
    if (startIdx < 0 || endIdx < 0 || endIdx <= startIdx) return null;
    return allTimes.sublist(startIdx, endIdx);
  }
}