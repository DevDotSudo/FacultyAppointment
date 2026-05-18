import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../shared/widgets/dialog_helper.dart';
import '../../domain/usecases/book_appointment_usecase.dart';

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key});
  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final _purposeCtrl = TextEditingController();
  final _bookUseCase = BookAppointmentUseCase();
  String? _selectedFacultyId;
  String? _selectedFacultyName;
  String? _selectedDate;
  String? _selectedTime;
  bool _isSubmitting = false;

  // Dynamic times based on faculty's set schedule
  List<String> _availableTimes = [];
  String? _selectedDayOfWeek;

  String _dayIndexToName(int index) {
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

  Future<void> _loadFacultyAvailability(String facultyId) async {
    setState(() {
      _availableTimes = [];
      _selectedTime = null;
    });
    try {
      final snap = await FirebaseFirestore.instance
          .collection('faculty_availability')
          .where('faculty_id', isEqualTo: facultyId)
          .get();

      // Get the day of week from selected date
      if (_selectedDate != null) {
        final parts = _selectedDate!.split('/');
        if (parts.length == 3) {
          final month = int.tryParse(parts[0]) ?? 1;
          final day = int.tryParse(parts[1]) ?? 1;
          final year = int.tryParse(parts[2]) ?? DateTime.now().year;
          final date = DateTime(year, month, day);
          _selectedDayOfWeek = _dayIndexToName(date.weekday);
        }
      }

      if (snap.docs.isEmpty) {
        // No schedule set - show all default times
        _availableTimes = _defaultTimes;
      } else {
        final times = <String>[];
        for (final doc in snap.docs) {
          final d = doc.data();
          final day = d['day'] as String? ?? '';
          final start = d['start_time'] as String? ?? '';
          final end = d['end_time'] as String? ?? '';

          // Show all schedules' times if no date selected yet
          if (_selectedDayOfWeek == null || day.toLowerCase() == _selectedDayOfWeek!.toLowerCase()) {
            // Generate time slots from start to end
            final startIdx = _defaultTimes.indexOf(start);
            final endIdx = _defaultTimes.indexOf(end);
            if (startIdx >= 0 && endIdx >= 0 && endIdx > startIdx) {
              for (int i = startIdx; i < endIdx; i++) {
                if (!times.contains(_defaultTimes[i])) {
                  times.add(_defaultTimes[i]);
                }
              }
            } else {
              // Fallback: show start time
              times.add('$start - $end');
            }
          }
        }
        _availableTimes = times;
      }
    } catch (e) {
      _availableTimes = _defaultTimes;
    }
    setState(() {});
  }

  static const _defaultTimes = ['8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM', '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM'];
  List<String> get _times => _availableTimes.isNotEmpty ? _availableTimes : _defaultTimes;

  @override
  void dispose() {
    _purposeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _selectedDate =
          '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkCardBg : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final fieldFill = isDark ? AppColors.darkInputBg : AppColors.lightInputBg;

    InputDecoration fieldDeco(String hint, {Widget? suffix, Widget? prefix}) => InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 13, color: mutedColor),
      suffixIcon: suffix,
      prefixIcon: prefix,
      filled: true, fillColor: fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    );

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        InkWell(onTap: () => context.pop(), borderRadius: BorderRadius.circular(8),
          child: Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: cardBg,
              borderRadius: BorderRadius.circular(8), border: Border.all(color: borderColor)),
            child: Icon(Icons.arrow_back_rounded, size: 18, color: textColor))),
        const SizedBox(width: 12),
        Text('Book Appointment', style: GoogleFonts.inter(
          fontSize: Responsive.h2(screenWidth).fontSize,
          fontWeight: FontWeight.bold,
          color: textColor)),
      ]),
      const SizedBox(height: 4),
      Padding(
        padding: const EdgeInsets.only(left: 44),
        child: Text('Fill in the details to request an appointment',
          style: GoogleFonts.inter(
            fontSize: Responsive.body(screenWidth).fontSize,
            color: mutedColor)),
      ),
      SizedBox(height: Responsive.s24),

      Container(
        padding: Responsive.cardPadding(screenWidth),
        decoration: BoxDecoration(color: cardBg,
          borderRadius: BorderRadius.circular(Responsive.cardRadius(screenWidth)),
          border: Border.all(color: borderColor, width: 0.5),
          boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Faculty
          _label('Select Faculty', textColor),
          SizedBox(height: Responsive.s8),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('faculty').snapshots(),
            builder: (context, snap) {
              final list = snap.hasData
                  ? snap.data!.docs.map((d) => {'id': d.id, 'name': (d.data() as Map)['full_name'] as String? ?? 'Unknown'}).toList()
                  : <Map<String, String>>[];
              return DropdownButtonFormField<String>(
                initialValue: _selectedFacultyId,
                items: list.map((f) => DropdownMenuItem<String>(value: f['id'], child: Text(f['name']!))).toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedFacultyId = v;
                    _selectedFacultyName = list.firstWhere((f) => f['id'] == v)['name'];
                  });
                  if (v != null) {
                    _loadFacultyAvailability(v);
                  }
                },
                decoration: fieldDeco('Choose a faculty member',
                  prefix: Icon(Icons.person_outline_rounded, size: 18, color: mutedColor)),
                style: GoogleFonts.inter(fontSize: 14, color: textColor),
              );
            },
          ),
          SizedBox(height: Responsive.s16),

          // Date & Time
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Date', textColor),
              SizedBox(height: Responsive.s8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(color: fieldFill, borderRadius: BorderRadius.circular(10), border: Border.all(color: borderColor)),
                  child: Row(children: [
                    Icon(Icons.calendar_today_rounded, size: 16, color: mutedColor),
                    const SizedBox(width: 8),
                    Text(_selectedDate ?? 'Pick a date', style: GoogleFonts.inter(fontSize: 13,
                      color: _selectedDate != null ? textColor : mutedColor)),
                  ]),
                ),
              ),
            ])),
            SizedBox(width: Responsive.s12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Time', textColor),
              SizedBox(height: Responsive.s8),
              DropdownButtonFormField<String>(
                initialValue: _selectedTime,
                items: _times.map((t) => DropdownMenuItem<String>(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _selectedTime = v),
                decoration: fieldDeco('Select time',
                  prefix: Icon(Icons.access_time_rounded, size: 18, color: mutedColor)),
                style: GoogleFonts.inter(fontSize: 14, color: textColor),
              ),
            ])),
          ]),
          SizedBox(height: Responsive.s16),

          // Purpose
          _label('Purpose', textColor),
          SizedBox(height: Responsive.s8),
          TextFormField(
            controller: _purposeCtrl,
            maxLines: 4,
            style: GoogleFonts.inter(fontSize: 14, color: textColor),
            decoration: fieldDeco('Describe the purpose of your appointment...'),
          ),
          SizedBox(height: Responsive.s24),

          SizedBox(
            width: double.infinity,
            height: Responsive.buttonHeight(screenWidth),
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : () {
                if (_selectedFacultyId == null || _selectedDate == null || _selectedTime == null || _purposeCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields'), backgroundColor: AppColors.danger));
                  return;
                }
                DialogHelper.showConfirmSubmitModal(context,
                  facultyName: _selectedFacultyName ?? 'Faculty',
                  date: _selectedDate!,
                  time: _selectedTime!,
                  onConfirm: () async {
                    setState(() => _isSubmitting = true);
                    try {
                      final snap = await FirebaseFirestore.instance.collection('students').doc(uid).get();
                      final studentName = snap.get('full_name') as String? ?? 'Student';
                      await _bookUseCase.call(
                        studentId: uid, studentName: studentName,
                        facultyId: _selectedFacultyId!, facultyName: _selectedFacultyName ?? 'Faculty',
                        facultyInitials: (_selectedFacultyName ?? 'F').split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase(),
                        date: _selectedDate!, time: _selectedTime!, purpose: _purposeCtrl.text.trim(),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Appointment submitted! ✓'), backgroundColor: AppColors.success));
                        context.pop();
                      }
                    } catch (e) {
                      if (context.mounted) DialogHelper.showErrorDialog(context, title: 'Error', message: e.toString());
                    } finally {
                      if (mounted) setState(() => _isSubmitting = false);
                    }
                  });
              },
              icon: _isSubmitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded, size: 16),
              label: Text(_isSubmitting ? 'Submitting...' : 'Submit Appointment',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ]),
      ),
    ]);
  }

  Widget _label(String text, Color color) => Text(text,
    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color, letterSpacing: 0.2));
}