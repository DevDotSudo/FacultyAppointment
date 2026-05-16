import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../shared/widgets/dialog_helper.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});
  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _courseCtrl = TextEditingController();
  bool _isSaving = false, _dataLoaded = false, _isEditing = false;

  @override
  void dispose() { _nameCtrl.dispose(); _phoneCtrl.dispose(); _courseCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await FirebaseFirestore.instance.collection('students').doc(uid).update({
        'full_name': _nameCtrl.text.trim(), 'phone': _phoneCtrl.text.trim(),
        'course': _courseCtrl.text.trim(), 'updated_at': FieldValue.serverTimestamp(),
      });
      if (mounted) { setState(() => _isEditing = false); ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated ✓'), backgroundColor: AppColors.success)); }
    } catch (e) {
      if (mounted) DialogHelper.showErrorDialog(context, title: 'Error', message: e.toString());
    } finally { if (mounted) setState(() => _isSaving = false); }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.textDark;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.textMuted;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('students').doc(uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final fullName = data['full_name'] as String? ?? 'Student';
        final email = data['email'] as String? ?? '';
        final phone = data['phone'] as String? ?? '';
        final studentId = data['student_id'] as String? ?? '';
        final course = data['course'] as String? ?? '';
        final initials = fullName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
        if (!_dataLoaded) { _nameCtrl.text = fullName; _phoneCtrl.text = phone; _courseCtrl.text = course; _dataLoaded = true; }

        return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('My Profile', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
            const Spacer(),
            _IconBtn(icon: _isEditing ? Icons.close_rounded : Icons.edit_rounded,
              onTap: () => setState(() => _isEditing = !_isEditing), isDark: isDark),
          ]),
          const SizedBox(height: 20),

          // Profile card
          _Card(isDark: isDark, child: Form(key: _formKey, child: Column(children: [
            // Avatar + name
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(child: Text(initials, style: GoogleFonts.inter(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
            ),
            const SizedBox(height: 12),
            Text(fullName, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
            Text(email, style: GoogleFonts.inter(fontSize: 13, color: mutedColor)),
            const SizedBox(height: 4),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Text('Student', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary))),
            const SizedBox(height: 20),
            Divider(color: isDark ? AppColors.darkBorder : const Color(0xFFF0F1F3)),
            const SizedBox(height: 16),

            if (_isEditing) ...[
              _profileField('Full Name', _nameCtrl, isDark, validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              _readonlyField('Email', email, isDark),
              const SizedBox(height: 12),
              _profileField('Phone Number', _phoneCtrl, isDark),
              const SizedBox(height: 12),
              _profileField('Course / Year', _courseCtrl, isDark),
              const SizedBox(height: 12),
              _readonlyField('Student ID', studentId, isDark),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 44, child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
                child: _isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Save Changes', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              )),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: OutlinedButton.icon(
                onPressed: () => DialogHelper.showChangePasswordModal(context),
                icon: const Icon(Icons.lock_outline_rounded, size: 16),
                label: const Text('Change Password'),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary,
                  side: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFEEEFF2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              )),
            ] else ...[
              _infoRow('Full Name', fullName, textColor, mutedColor),
              _infoRow('Email', email, textColor, mutedColor),
              _infoRow('Phone', phone.isNotEmpty ? phone : '—', textColor, mutedColor),
              _infoRow('Course / Year', course.isNotEmpty ? course : '—', textColor, mutedColor),
              _infoRow('Student ID', studentId.isNotEmpty ? studentId : '—', textColor, mutedColor),
            ],
          ]))),
          const SizedBox(height: 20),

          // Stats
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('appointment_requests').where('student_id', isEqualTo: uid).snapshots(),
            builder: (context, snap) {
              int total = 0, pending = 0, accepted = 0, rejected = 0;
              if (snap.hasData) {
                for (final doc in snap.data!.docs) {
                  final s = doc['status'] as String? ?? '';
                  total++;
                  if (s == 'pending') { pending++; }
                  else if (s == 'accepted') { accepted++; }
                  else if (s == 'rejected') { rejected++; }
                }
              }
              return LayoutBuilder(builder: (context, constraints) {
                final twoCol = Responsive.statCardsTwoCol(constraints.maxWidth);
                final stats = [
                  ('Total', total, AppColors.info),
                  ('Pending', pending, AppColors.warning),
                  ('Accepted', accepted, AppColors.success),
                  ('Rejected', rejected, AppColors.danger),
                ];
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Appointment Stats', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
                  const SizedBox(height: 12),
                  if (twoCol)
                    Column(children: [
                      Row(children: [
                        Expanded(child: _statMini(stats[0].$1, stats[0].$2, stats[0].$3, isDark)),
                        const SizedBox(width: 10),
                        Expanded(child: _statMini(stats[1].$1, stats[1].$2, stats[1].$3, isDark)),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(child: _statMini(stats[2].$1, stats[2].$2, stats[2].$3, isDark)),
                        const SizedBox(width: 10),
                        Expanded(child: _statMini(stats[3].$1, stats[3].$2, stats[3].$3, isDark)),
                      ]),
                    ])
                  else
                    Row(children: [
                      Expanded(child: _statMini(stats[0].$1, stats[0].$2, stats[0].$3, isDark)),
                      const SizedBox(width: 10),
                      Expanded(child: _statMini(stats[1].$1, stats[1].$2, stats[1].$3, isDark)),
                      const SizedBox(width: 10),
                      Expanded(child: _statMini(stats[2].$1, stats[2].$2, stats[2].$3, isDark)),
                      const SizedBox(width: 10),
                      Expanded(child: _statMini(stats[3].$1, stats[3].$2, stats[3].$3, isDark)),
                    ]),
                ]);
              });
            },
          ),
        ]));
      },
    );
  }
}

// ── Shared helpers ──────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _Card({required this.child, required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFEEEFF2)),
      boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: child,
  );
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  const _IconBtn({required this.icon, required this.onTap, required this.isDark});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap, borderRadius: BorderRadius.circular(8),
    child: Container(padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFEEEFF2))),
      child: Icon(icon, size: 18, color: AppColors.primary)),
  );
}

Widget _profileField(String label, TextEditingController ctrl, bool isDark, {String? Function(String?)? validator}) {
  final border = isDark ? AppColors.darkBorder : const Color(0xFFEEEFF2);
  return TextFormField(
    controller: ctrl,
    validator: validator,
    style: GoogleFonts.inter(fontSize: 14, color: isDark ? AppColors.darkText : AppColors.textDark),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.darkMuted : AppColors.textMuted),
      filled: true, fillColor: isDark ? AppColors.darkBg : const Color(0xFFF8F9FB),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );
}

Widget _readonlyField(String label, String value, bool isDark) {
  return TextFormField(
    initialValue: value, readOnly: true,
    style: GoogleFonts.inter(fontSize: 14, color: isDark ? AppColors.darkMuted : AppColors.textMuted),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.darkMuted : AppColors.textMuted),
      filled: true, fillColor: isDark ? AppColors.darkBg : const Color(0xFFF3F4F6),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );
}

Widget _infoRow(String label, String value, Color textColor, Color mutedColor) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 120, child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: mutedColor))),
      Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 13, color: textColor))),
    ]),
  );
}

Widget _statMini(String label, int count, Color accent, bool isDark) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFEEEFF2)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$count', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: accent)),
      Text(label, style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppColors.darkMuted : AppColors.textMuted)),
    ]),
  );
}
