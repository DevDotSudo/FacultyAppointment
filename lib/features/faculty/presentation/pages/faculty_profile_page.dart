import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/dialog_helper.dart';
import '../../../shared/widgets/skeleton_loader.dart';
// Reuse helpers from student_profile_page via local definitions

class FacultyProfilePage extends StatefulWidget {
  const FacultyProfilePage({super.key});
  @override
  State<FacultyProfilePage> createState() => _FacultyProfilePageState();
}

class _FacultyProfilePageState extends State<FacultyProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  final _specCtrl = TextEditingController();
  final _officeCtrl = TextEditingController();
  bool _isSaving = false, _dataLoaded = false, _isEditing = false;
  late final Future<DocumentSnapshot> _profileFuture;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    _profileFuture = FirebaseFirestore.instance.collection('faculty').doc(uid).get();
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose(); _deptCtrl.dispose();
    _specCtrl.dispose(); _officeCtrl.dispose(); super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await FirebaseFirestore.instance.collection('faculty').doc(uid).update({
        'full_name': _nameCtrl.text.trim(), 'phone': _phoneCtrl.text.trim(),
        'department': _deptCtrl.text.trim(), 'specialization': _specCtrl.text.trim(),
        'office_location': _officeCtrl.text.trim(), 'updated_at': FieldValue.serverTimestamp(),
      });
      if (mounted) { setState(() => _isEditing = false); ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated ✓'), backgroundColor: AppColors.success)); }
    } catch (e) {
      if (mounted) DialogHelper.showErrorDialog(context, title: 'Error', message: e.toString());
    } finally { if (mounted) setState(() => _isSaving = false); }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.textDark;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.textMuted;
    final border = isDark ? AppColors.darkBorder : const Color(0xFFEEEFF2);

    return FutureBuilder<DocumentSnapshot>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SkeletonProfileHeader(),
                const SizedBox(height: 24),
                ...List.generate(
                  6,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SkeletonLoader.rectangle(
                      width: double.infinity,
                      height: 56,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final fullName = data['full_name'] as String? ?? 'Faculty';
        final email = data['email'] as String? ?? '';
        final phone = data['phone'] as String? ?? '';
        final dept = data['department'] as String? ?? '';
        final spec = data['specialization'] as String? ?? '';
        final office = data['office_location'] as String? ?? '';
        final initials = fullName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
        if (!_dataLoaded) {
          _nameCtrl.text = fullName; _phoneCtrl.text = phone; _deptCtrl.text = dept;
          _specCtrl.text = spec; _officeCtrl.text = office; _dataLoaded = true;
        }

        InputDecoration fieldDeco(String label) => InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(fontSize: 12, color: mutedColor),
          filled: true, fillColor: isDark ? AppColors.darkBg : const Color(0xFFF8F9FB),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        );

        return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('My Profile', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
            const Spacer(),
            InkWell(
              onTap: () => setState(() => _isEditing = !_isEditing),
              borderRadius: BorderRadius.circular(8),
              child: Container(padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(8), border: Border.all(color: border)),
                child: Icon(_isEditing ? Icons.close_rounded : Icons.edit_rounded, size: 18, color: AppColors.primary)),
            ),
          ]),
          const SizedBox(height: 20),

          Container(
            width: double.infinity, padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(12), border: Border.all(color: border),
              boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Form(key: _formKey, child: Column(children: [
              Container(width: 72, height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                  borderRadius: BorderRadius.circular(20)),
                child: Center(child: Text(initials, style: GoogleFonts.inter(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)))),
              const SizedBox(height: 12),
              Text(fullName, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
              Text(email, style: GoogleFonts.inter(fontSize: 13, color: mutedColor)),
              const SizedBox(height: 4),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Text('Faculty', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success))),
              const SizedBox(height: 20),
              Divider(color: isDark ? AppColors.darkBorder : const Color(0xFFF0F1F3)),
              const SizedBox(height: 16),

              if (_isEditing) ...[
                TextFormField(controller: _nameCtrl, validator: (v) => v!.isEmpty ? 'Required' : null,
                  style: GoogleFonts.inter(fontSize: 14, color: textColor), decoration: fieldDeco('Full Name')),
                const SizedBox(height: 12),
                TextFormField(initialValue: email, readOnly: true,
                  style: GoogleFonts.inter(fontSize: 14, color: mutedColor),
                  decoration: InputDecoration(labelText: 'Email', labelStyle: GoogleFonts.inter(fontSize: 12, color: mutedColor),
                    filled: true, fillColor: isDark ? AppColors.darkBg : const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12))),
                const SizedBox(height: 12),
                TextFormField(controller: _phoneCtrl, style: GoogleFonts.inter(fontSize: 14, color: textColor), decoration: fieldDeco('Phone Number')),
                const SizedBox(height: 12),
                TextFormField(controller: _deptCtrl, style: GoogleFonts.inter(fontSize: 14, color: textColor), decoration: fieldDeco('Department')),
                const SizedBox(height: 12),
                TextFormField(controller: _specCtrl, style: GoogleFonts.inter(fontSize: 14, color: textColor), decoration: fieldDeco('Specialization')),
                const SizedBox(height: 12),
                TextFormField(controller: _officeCtrl, style: GoogleFonts.inter(fontSize: 14, color: textColor), decoration: fieldDeco('Office Location')),
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
                    side: BorderSide(color: border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                )),
              ] else ...[
                _row('Full Name', fullName, textColor, mutedColor),
                _row('Email', email, textColor, mutedColor),
                _row('Phone', phone.isNotEmpty ? phone : '—', textColor, mutedColor),
                _row('Department', dept.isNotEmpty ? dept : '—', textColor, mutedColor),
                _row('Specialization', spec.isNotEmpty ? spec : '—', textColor, mutedColor),
                _row('Office', office.isNotEmpty ? office : '—', textColor, mutedColor),
              ],
            ])),
          ),
        ]));
      },
    );
  }

  Widget _row(String label, String value, Color textColor, Color mutedColor) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 120, child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: mutedColor))),
      Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 13, color: textColor))),
    ]),
  );

}
