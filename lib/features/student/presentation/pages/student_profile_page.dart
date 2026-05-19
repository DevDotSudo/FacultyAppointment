import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../shared/widgets/dialog_helper.dart';
import '../../../shared/widgets/skeleton_loader.dart';

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
  late final Future<DocumentSnapshot> _profileFuture;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    _profileFuture = FirebaseFirestore.instance.collection('students').doc(uid).get();
  }

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surfaceColor = isDark ? AppColors.darkCardBg : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

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
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SkeletonLoader.rectangle(
                    width: double.infinity,
                    height: 56,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SkeletonLoader.rectangle(
                    width: double.infinity,
                    height: 56,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SkeletonLoader.rectangle(
                    width: double.infinity,
                    height: 56,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SkeletonLoader.rectangle(
                    width: double.infinity,
                    height: 56,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          );
        }
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final fullName = data['full_name'] as String? ?? 'Student';
        final email = data['email'] as String? ?? '';
        final phone = data['phone'] as String? ?? '';
        final studentId = data['student_id'] as String? ?? '';
        final course = data['course'] as String? ?? '';
        final initials = fullName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
        if (!_dataLoaded) { _nameCtrl.text = fullName; _phoneCtrl.text = phone; _courseCtrl.text = course; _dataLoaded = true; }

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header with edit button
          Row(children: [
            Text('My Profile', style: GoogleFonts.inter(
              fontSize: Responsive.h2(screenWidth).fontSize,
              fontWeight: FontWeight.bold,
              color: textColor)),
            const Spacer(),
            _IconBtn(icon: _isEditing ? Icons.close_rounded : Icons.edit_rounded,
              onTap: () => setState(() => _isEditing = !_isEditing), isDark: isDark),
          ]),
          SizedBox(height: Responsive.s20),

          // Profile card
          Container(
            padding: Responsive.cardPadding(screenWidth),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(Responsive.cardRadius(screenWidth)),
              border: Border.all(color: borderColor, width: 0.5),
            ),
            child: Form(key: _formKey, child: Column(children: [
              Container(width: 72, height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(child: Text(initials, style: GoogleFonts.inter(color: Colors.white,
                    fontSize: 22, fontWeight: FontWeight.bold)))),
              SizedBox(height: Responsive.s12),
              Text(fullName, style: GoogleFonts.inter(
                fontSize: Responsive.h4(screenWidth).fontSize,
                fontWeight: FontWeight.w600,
                color: textColor)),
              Text(email, style: GoogleFonts.inter(
                fontSize: Responsive.small(screenWidth).fontSize,
                color: mutedColor)),
              SizedBox(height: Responsive.s4),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Text('Student', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary))),
              SizedBox(height: Responsive.s20),
              Divider(color: borderColor),
              SizedBox(height: Responsive.s16),

              if (_isEditing) ...[
                _profileField('Full Name', _nameCtrl, isDark, borderColor, validator: (v) => v!.isEmpty ? 'Required' : null),
                SizedBox(height: Responsive.s12),
                _readonlyField('Email', email, isDark, borderColor),
                SizedBox(height: Responsive.s12),
                _profileField('Phone Number', _phoneCtrl, isDark, borderColor),
                SizedBox(height: Responsive.s12),
                _profileField('Course / Year', _courseCtrl, isDark, borderColor),
                SizedBox(height: Responsive.s12),
                _readonlyField('Student ID', studentId, isDark, borderColor),
                SizedBox(height: Responsive.s20),
                SizedBox(width: double.infinity, height: Responsive.buttonHeight(screenWidth), child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Save Changes', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                )),
                SizedBox(height: Responsive.s12),
                SizedBox(width: double.infinity, child: OutlinedButton.icon(
                  onPressed: () => DialogHelper.showChangePasswordModal(context),
                  icon: const Icon(Icons.lock_outline_rounded, size: 16),
                  label: const Text('Change Password'),
                )),
              ] else ...[
                _infoRow('Full Name', fullName, textColor, mutedColor, screenWidth),
                _infoRow('Email', email, textColor, mutedColor, screenWidth),
                _infoRow('Phone', phone.isNotEmpty ? phone : '—', textColor, mutedColor, screenWidth),
                _infoRow('Course / Year', course.isNotEmpty ? course : '—', textColor, mutedColor, screenWidth),
                _infoRow('Student ID', studentId.isNotEmpty ? studentId : '—', textColor, mutedColor, screenWidth),
              ],
            ])),
          ),
        ]);
      },
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap; final bool isDark;
  const _IconBtn({required this.icon, required this.onTap, required this.isDark});
  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardBg : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }
}

Widget _profileField(String label, TextEditingController ctrl, bool isDark, Color borderColor, {String? Function(String?)? validator}) {
  return TextFormField(
    controller: ctrl, validator: validator,
    style: GoogleFonts.inter(fontSize: 14, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
      filled: true, fillColor: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    ),
  );
}

Widget _readonlyField(String label, String value, bool isDark, Color borderColor) {
  return TextFormField(
    initialValue: value, readOnly: true,
    style: GoogleFonts.inter(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
      filled: true, fillColor: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    ),
  );
}

Widget _infoRow(String label, String value, Color textColor, Color mutedColor, double screenWidth) {
  return Padding(padding: EdgeInsets.only(bottom: Responsive.s12),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: screenWidth < Responsive.tablet ? 100 : 120,
        child: Text(label, style: GoogleFonts.inter(
          fontSize: Responsive.small(screenWidth).fontSize,
          fontWeight: FontWeight.w500,
          color: mutedColor))),
      Expanded(child: Text(value, style: GoogleFonts.inter(
        fontSize: Responsive.body(screenWidth).fontSize,
        color: textColor))),
    ]));
}
