import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/role_selector_widget.dart';
import '../../domain/entities/user_entity.dart';
import '../../../shared/widgets/dialog_helper.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _departmentCtrl = TextEditingController();
  final _specializationCtrl = TextEditingController();
  final _officeLocationCtrl = TextEditingController();
  final _studentIdCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirmPass = true;
  bool _isLoading = false;
  String _selectedRole = 'student';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _departmentCtrl.dispose();
    _specializationCtrl.dispose();
    _officeLocationCtrl.dispose();
    _studentIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await context.read<AuthCubit>().registerUser(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      role: _selectedRole,
      fullName: _fullNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      department: _selectedRole == 'faculty' ? _departmentCtrl.text.trim() : null,
      specialization: _selectedRole == 'faculty' ? _specializationCtrl.text.trim() : null,
      officeLocation: _selectedRole == 'faculty' ? _officeLocationCtrl.text.trim() : null,
      studentId: _selectedRole == 'student' ? _studentIdCtrl.text.trim() : null,
    );
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          if (state.user.role == UserRole.student) context.goNamed('student-dashboard');
          else context.goNamed('faculty-dashboard');
        } else if (state is AuthFailure) {
          DialogHelper.showErrorDialog(context, title: 'Registration failed', message: state.message);
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: 420,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF8B5CF6)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(height: 12),
                    Text('Create your account', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: textColor)),
                    const SizedBox(height: 4),
                    Text('Fill in the details to get started', style: GoogleFonts.inter(fontSize: 13, color: mutedColor)),
                    const SizedBox(height: 14),

                    Text('I AM A', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: textColor, letterSpacing: 0.5)),
                    const SizedBox(height: 6),
                    RoleSelectorWidget(selectedRole: _selectedRole, onRoleChanged: (r) => setState(() => _selectedRole = r)),
                    const SizedBox(height: 16),

                    AuthTextField(label: 'Full name', hintText: 'John Doe', controller: _fullNameCtrl,
                      prefixIcon: const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.textHint),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                    const SizedBox(height: 12),
                    AuthTextField(label: 'Email', hintText: 'you@example.com', controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.mail_outline_rounded, size: 18, color: AppColors.textHint),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : (!v.contains('@') ? 'Invalid email' : null)),
                    const SizedBox(height: 12),
                    AuthTextField(label: 'Phone', hintText: '+63 912 345 6789', controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_outlined, size: 18, color: AppColors.textHint),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                    const SizedBox(height: 12),

                    if (_selectedRole == 'faculty') ...[
                      AuthTextField(label: 'Department', hintText: 'e.g. Computer Science', controller: _departmentCtrl,
                        prefixIcon: const Icon(Icons.business_outlined, size: 18, color: AppColors.textHint),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                      const SizedBox(height: 12),
                      AuthTextField(label: 'Specialization', hintText: 'e.g. Machine Learning', controller: _specializationCtrl,
                        prefixIcon: const Icon(Icons.science_outlined, size: 18, color: AppColors.textHint),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                      const SizedBox(height: 12),
                      AuthTextField(label: 'Office', hintText: 'e.g. Room 301', controller: _officeLocationCtrl,
                        prefixIcon: const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textHint),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                      const SizedBox(height: 12),
                    ],
                    if (_selectedRole == 'student') ...[
                      AuthTextField(label: 'Student ID', hintText: 'e.g. 2021-00123', controller: _studentIdCtrl,
                        prefixIcon: const Icon(Icons.badge_outlined, size: 18, color: AppColors.textHint),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                      const SizedBox(height: 12),
                    ],

                    AuthTextField(label: 'Password', hintText: 'At least 6 characters', controller: _passwordCtrl,
                      obscureText: _obscurePass,
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.textHint),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscurePass = !_obscurePass),
                        icon: Icon(_obscurePass ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18, color: AppColors.textHint)),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : (v.length < 6 ? 'Minimum 6 characters' : null)),
                    const SizedBox(height: 12),
                    AuthTextField(label: 'Confirm password', hintText: 'Re-enter your password', controller: _confirmPasswordCtrl,
                      obscureText: _obscureConfirmPass,
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.textHint),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
                        icon: Icon(_obscureConfirmPass ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18, color: AppColors.textHint)),
                      validator: (v) => v != _passwordCtrl.text ? 'Passwords do not match' : null),
                    const SizedBox(height: 14),

                    SizedBox(width: double.infinity, height: 44, child: ElevatedButton(
                      onPressed: _isLoading ? null : _onRegister,
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('Create account', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                    )),
                    const SizedBox(height: 12),

                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('Already have an account? ', style: GoogleFonts.inter(fontSize: 13, color: mutedColor)),
                      GestureDetector(
                        onTap: () => context.goNamed('login'),
                        child: Text('Sign in', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}