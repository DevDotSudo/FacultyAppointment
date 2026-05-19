import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../shared/widgets/custom_dialog.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../../../core/utils/encryption_service.dart';

class BookAppointmentPage extends StatefulWidget {
  final String? preselectedFacultyId;
  final String? preselectedFacultyName;
  final String? preselectedDept;

  const BookAppointmentPage({
    super.key,
    this.preselectedFacultyId,
    this.preselectedFacultyName,
    this.preselectedDept,
  });

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final _purposeCtrl = TextEditingController();

  String? _dept;
  String? _facultyId;
  String? _facultyName;
  String? _scheduleId;
  Map<String, dynamic>? _schedule;

  List<String> _depts = [];
  List<Map<String, dynamic>> _faculty = [];
  List<Map<String, dynamic>> _schedules = [];

  bool _loadingDepts = true;
  bool _loadingFaculty = false;
  bool _loadingSchedules = false;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDepts();
  }

  @override
  void dispose() {
    _purposeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDepts() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('faculty').get();
      final depts = snap.docs
          .map((d) => (d.data()['department'] as String? ?? '').trim())
          .where((d) => d.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      if (!mounted) return;
      setState(() { _depts = depts; _loadingDepts = false; });

      // Pre-select faculty if navigated from FacultyListPage
      if (widget.preselectedDept != null && depts.contains(widget.preselectedDept)) {
        setState(() => _dept = widget.preselectedDept);
        await _loadFaculty(widget.preselectedDept!);
        if (widget.preselectedFacultyId != null && mounted) {
          setState(() {
            _facultyId = widget.preselectedFacultyId;
            _facultyName = widget.preselectedFacultyName;
          });
          await _loadSchedules(widget.preselectedFacultyId!);
        }
      }
    } catch (e) {
      if (mounted) setState(() { _loadingDepts = false; _error = 'Failed to load departments.'; });
    }
  }

  Future<void> _loadFaculty(String dept) async {
    setState(() {
      _loadingFaculty = true;
      _faculty = [];
      _facultyId = null;
      _facultyName = null;
      _schedules = [];
      _scheduleId = null;
      _schedule = null;
    });
    try {
      final snap = await FirebaseFirestore.instance
          .collection('faculty')
          .where('department', isEqualTo: dept)
          .get();
      if (mounted) {
        setState(() {
          _faculty = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
          _loadingFaculty = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loadingFaculty = false; });
    }
  }

  Future<void> _loadSchedules(String facultyId) async {
    setState(() {
      _loadingSchedules = true;
      _schedules = [];
      _scheduleId = null;
      _schedule = null;
    });
    try {
      final now = DateTime.now();
      final snap = await FirebaseFirestore.instance
          .collection('faculty_availability')
          .where('faculty_id', isEqualTo: facultyId)
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
          final date = rawDate.toDate();
          if (date.isBefore(DateTime(now.year, now.month, now.day))) continue;
        }
        available.add({'id': doc.id, ...d});
      }

      if (mounted) setState(() { _schedules = available; _loadingSchedules = false; });
    } catch (e) {
      if (mounted) setState(() { _loadingSchedules = false; });
    }
  }

  Future<void> _submit() async {
    if (_facultyId == null || _scheduleId == null || _purposeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please complete all steps'), backgroundColor: AppColors.danger));
      return;
    }

    final s = _schedule!;
    final rawDate = s['date'];
    final dateStr = rawDate is Timestamp
        ? DateFormat('EEE, MMM d, yyyy').format(rawDate.toDate())
        : (s['day'] as String? ?? '');
    final timeStr = '${s['start_time']} – ${s['end_time']}';

    if (!mounted) return;
    final confirmed = await CustomDialog.show<bool>(
      context: context,
      title: 'Confirm Appointment',
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        const SizedBox(width: 8),
        ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Confirm')),
      ],
      child: Text(
        'Book with $_facultyName\n$dateStr · $timeStr',
        style: GoogleFonts.inter(fontSize: 14,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _submitting = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final studentSnap = await FirebaseFirestore.instance.collection('students').doc(uid).get();
      final studentName = studentSnap.data()?['full_name'] as String? ?? 'Student';

      // Use Firestore transaction to prevent race condition
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final slotRef = FirebaseFirestore.instance.collection('faculty_availability').doc(_scheduleId!);
        final slotDoc = await transaction.get(slotRef);

        if (!slotDoc.exists) {
          throw Exception('Schedule slot no longer available');
        }

        final slotData = slotDoc.data()!;
        final max = (slotData['max_slots'] as num?)?.toInt() ?? 1;
        final booked = (slotData['booked_slots'] as num?)?.toInt() ?? 0;

        if (booked >= max) {
          throw Exception('This slot is now fully booked. Please select another.');
        }

        // Check duplicate within transaction
        final dupSnap = await FirebaseFirestore.instance
            .collection('appointment_requests')
            .where('student_id', isEqualTo: uid)
            .where('schedule_id', isEqualTo: _scheduleId)
            .where('status', whereIn: ['pending', 'accepted']).get();
        if (dupSnap.docs.isNotEmpty) {
          throw Exception('You already have an active booking for this slot');
        }

        // Atomically increment booked_slots
        transaction.update(slotRef, {'booked_slots': FieldValue.increment(1)});

        // Create appointment request via transaction
        final requestRef = FirebaseFirestore.instance.collection('appointment_requests').doc();
        final requestData = {
          'student_id': uid,
          'student_name': studentName,
          'faculty_id': _facultyId!,
          'faculty_name': _facultyName ?? 'Faculty',
          'faculty_initials': (_facultyName ?? 'F')
              .split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase(),
          'date': dateStr,
          'time': timeStr,
          'purpose': _purposeCtrl.text.trim(),
          'schedule_id': _scheduleId,
          'status': 'pending',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        };
        transaction.set(requestRef, EncryptionService.encryptFields(requestData));
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Appointment submitted! ✓'), backgroundColor: AppColors.success));
      context.pop();
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Firebase error: ${e.message ?? e.code}'),
          backgroundColor: AppColors.danger));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.danger));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // Step completion helpers
  bool get _step1Done => _dept != null;
  bool get _step2Done => _facultyId != null;
  bool get _step3Done => _scheduleId != null;
  bool get _step4Done => _purposeCtrl.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkCardBg : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final fill = isDark ? AppColors.darkInputBg : AppColors.lightInputBg;

    InputDecoration deco(String hint, {Widget? prefix}) => InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 13, color: mutedColor),
      prefixIcon: prefix,
      filled: true, fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    );

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        InkWell(
          onTap: () => context.pop(),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: borderColor)),
            child: Icon(Icons.arrow_back_rounded, size: 18, color: textColor),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Book Appointment',
              style: GoogleFonts.inter(fontSize: Responsive.h2(w).fontSize, fontWeight: FontWeight.bold, color: textColor)),
          Text('Request a consultation with a faculty member',
              style: GoogleFonts.inter(fontSize: Responsive.body(w).fontSize, color: mutedColor)),
        ])),
      ]),
      SizedBox(height: Responsive.s24),

      if (_error != null)
        _infoBox(_error!, AppColors.danger, isDark),

      // ── Step 1 – Department ──
      _stepCard(
        stepNum: '1',
        title: 'Select Department',
        isDone: _step1Done,
        textColor: textColor,
        cardBg: cardBg,
        borderColor: borderColor,
        isDark: isDark,
        child: _loadingDepts
          ? SkeletonLoader.rectangle(width: double.infinity, height: 48, borderRadius: BorderRadius.circular(10))
          : DropdownButtonFormField<String>(
              initialValue: _depts.contains(_dept) ? _dept : null,
              items: _depts.map((d) => DropdownMenuItem(value: d, child: Text(d, style: GoogleFonts.inter(fontSize: 14, color: textColor)))).toList(),
              onChanged: (v) { if (v != null) { setState(() => _dept = v); _loadFaculty(v); } },
              decoration: deco('Choose a department', prefix: Icon(Icons.business_rounded, size: 18, color: mutedColor)),
              style: GoogleFonts.inter(fontSize: 14, color: textColor),
            ),
      ),
      SizedBox(height: Responsive.s12),

      // ── Step 2 – Faculty ──
      _stepCard(
        stepNum: '2',
        title: 'Select Faculty',
        isDone: _step2Done,
        textColor: textColor,
        cardBg: cardBg,
        borderColor: borderColor,
        isDark: isDark,
        child: _loadingFaculty
          ? SkeletonLoader.rectangle(width: double.infinity, height: 48, borderRadius: BorderRadius.circular(10))
          : _dept != null && _faculty.isEmpty
            ? _infoBox('No faculty found in this department.', AppColors.statusPending, isDark)
            : DropdownButtonFormField<String>(
                initialValue: _faculty.any((f) => f['id'] == _facultyId) ? _facultyId : null,
                items: _faculty.map((f) {
                  final name = f['full_name'] as String? ?? f['fullName'] as String? ?? 'Unknown';
                  final spec = f['specialization'] as String? ?? '';
                  final label = spec.isNotEmpty ? '$name — $spec' : name;
                  return DropdownMenuItem<String>(
                    value: f['id'] as String,
                    child: Text(label, style: GoogleFonts.inter(fontSize: 14, color: textColor), overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: _dept == null ? null : (v) {
                  if (v == null) return;
                  final f = _faculty.firstWhere((x) => x['id'] == v, orElse: () => {});
                  if (f.isEmpty) return;
                  setState(() {
                    _facultyId = v;
                    _facultyName = f['full_name'] as String? ?? f['fullName'] as String? ?? 'Faculty';
                  });
                  _loadSchedules(v);
                },
                decoration: deco('Choose a faculty member', prefix: Icon(Icons.person_outline_rounded, size: 18, color: mutedColor)),
                style: GoogleFonts.inter(fontSize: 14, color: textColor),
              ),
      ),
      SizedBox(height: Responsive.s12),

      // ── Step 3 – Schedule ──
      _stepCard(
        stepNum: '3',
        title: 'Select Available Schedule',
        isDone: _step3Done,
        textColor: textColor,
        cardBg: cardBg,
        borderColor: borderColor,
        isDark: isDark,
        child: _loadingSchedules
          ? Column(children: List.generate(3, (_) => const Padding(padding: EdgeInsets.only(bottom: 8), child: SkeletonScheduleItem())))
          : _facultyId != null && _schedules.isEmpty
            ? _infoBox('No available schedules for this faculty.', AppColors.statusPending, isDark)
            : Column(children: _schedules.map((s) {
                final id = s['id'] as String;
                final selected = _scheduleId == id;
                final max = (s['max_slots'] as num?)?.toInt() ?? 1;
                final booked = (s['booked_slots'] as num?)?.toInt() ?? 0;
                final remaining = max - booked;
                final rawDate = s['date'];
                final dateStr = rawDate is Timestamp
                    ? DateFormat('EEE, MMM d, yyyy').format(rawDate.toDate())
                    : (s['day'] as String? ?? '');
                final isOnline = (s['consultation_type'] as String? ?? '') == 'online';
                final location = s['location_or_link'] as String? ?? '';

                return GestureDetector(
                  onTap: () => setState(() { _scheduleId = id; _schedule = s; }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08) : fill,
                      border: Border.all(color: selected ? AppColors.primary : borderColor, width: selected ? 1.5 : 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(children: [
                      Container(
                        width: 18, height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: selected ? AppColors.primary : borderColor, width: 2),
                          color: selected ? AppColors.primary : Colors.transparent,
                        ),
                        child: selected ? const Icon(Icons.check, size: 11, color: Colors.white) : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Icon(Icons.calendar_today_rounded, size: 13, color: mutedColor),
                          const SizedBox(width: 4),
                          Flexible(child: Text(dateStr, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: textColor))),
                        ]),
                        const SizedBox(height: 3),
                        Wrap(spacing: 8, children: [
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.access_time_rounded, size: 13, color: mutedColor),
                            const SizedBox(width: 4),
                            Text('${s['start_time']} – ${s['end_time']}',
                                style: GoogleFonts.inter(fontSize: 12, color: mutedColor)),
                          ]),
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(isOnline ? Icons.videocam_rounded : Icons.location_on_rounded,
                                size: 13, color: isOnline ? AppColors.primary : AppColors.success),
                            const SizedBox(width: 3),
                            Text(isOnline ? 'Online' : 'Face-to-face',
                                style: GoogleFonts.inter(fontSize: 12,
                                    color: isOnline ? AppColors.primary : AppColors.success)),
                          ]),
                        ]),
                        if (location.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(location,
                                style: GoogleFonts.inter(fontSize: 11, color: mutedColor),
                                overflow: TextOverflow.ellipsis),
                          ),
                      ])),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (remaining <= 2 ? AppColors.statusPending : AppColors.statusAccepted)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('$remaining left',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                                color: remaining <= 2 ? AppColors.statusPending : AppColors.statusAccepted)),
                      ),
                    ]),
                  ),
                );
              }).toList()),
      ),
      SizedBox(height: Responsive.s12),

      // ── Step 4 – Purpose ──
      _stepCard(
        stepNum: '4',
        title: 'Purpose / Details',
        isDone: _step4Done,
        textColor: textColor,
        cardBg: cardBg,
        borderColor: borderColor,
        isDark: isDark,
        child: TextFormField(
          controller: _purposeCtrl,
          maxLines: 4,
          onChanged: (_) => setState(() {}),
          style: GoogleFonts.inter(fontSize: 14, color: textColor),
          decoration: deco('Describe the purpose of your appointment...'),
        ),
      ),
      SizedBox(height: Responsive.s16),

      // ── Summary Card ──
      if (_step1Done && _step2Done && _step3Done) ...[
        Container(
          padding: Responsive.cardPadding(w),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.05),
            borderRadius: BorderRadius.circular(Responsive.cardRadius(w)),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.summarize_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Booking Summary', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ]),
            const SizedBox(height: 10),
            _summaryRow(Icons.business_rounded, 'Department', _dept ?? '', textColor, mutedColor),
            const SizedBox(height: 6),
            _summaryRow(Icons.person_rounded, 'Faculty', _facultyName ?? '', textColor, mutedColor),
            const SizedBox(height: 6),
            if (_schedule != null) ...[
              _summaryRow(
                Icons.calendar_today_rounded,
                'Schedule',
                () {
                  final rawDate = _schedule!['date'];
                  return rawDate is Timestamp
                      ? DateFormat('EEE, MMM d').format(rawDate.toDate())
                      : (_schedule!['day'] as String? ?? '');
                }(),
                textColor,
                mutedColor,
              ),
              const SizedBox(height: 6),
              _summaryRow(Icons.access_time_rounded, 'Time', '${_schedule!['start_time']} – ${_schedule!['end_time']}', textColor, mutedColor),
            ],
          ]),
        ),
        SizedBox(height: Responsive.s16),
      ],

      // ── Submit Button ──
      SizedBox(
        width: double.infinity,
        height: Responsive.buttonHeight(w),
        child: ElevatedButton.icon(
          onPressed: _submitting ? null : _submit,
          icon: _submitting
              ? const SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.send_rounded, size: 16),
          label: Text(_submitting ? 'Submitting...' : 'Submit Appointment Request',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
        ),
      ),
    ]);
  }

  // ── Step card with completion indicator ──
  Widget _stepCard({
    required String stepNum,
    required String title,
    required bool isDone,
    required Color textColor,
    required Color cardBg,
    required Color borderColor,
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDone ? AppColors.success.withValues(alpha: 0.4) : borderColor,
          width: isDone ? 1.2 : 0.5,
        ),
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 24, height: 24,
            decoration: BoxDecoration(
              color: isDone ? AppColors.success : AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                color: (isDone ? AppColors.success : AppColors.primary).withValues(alpha: 0.3),
                blurRadius: 6, offset: const Offset(0, 2),
              )],
            ),
            child: Center(child: isDone
              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
              : Text(stepNum, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 10),
          Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
          if (isDone) ...[
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('Done', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.success)),
            ),
          ],
        ]),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value, Color textColor, Color mutedColor) {
    return Row(children: [
      Icon(icon, size: 14, color: mutedColor),
      const SizedBox(width: 8),
      Text('$label: ', style: GoogleFonts.inter(fontSize: 12, color: mutedColor)),
      Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textColor))),
    ]);
  }

  Widget _infoBox(String msg, Color color, bool isDark) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Row(children: [
      Icon(Icons.info_outline_rounded, size: 16, color: color),
      const SizedBox(width: 8),
      Expanded(child: Text(msg, style: GoogleFonts.inter(fontSize: 13, color: color))),
    ]),
  );
}
