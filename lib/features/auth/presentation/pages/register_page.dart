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
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          if (state.user.role == UserRole.student) {
            context.goNamed('student-dashboard');
          } else {
            context.goNamed('faculty-dashboard');
          }
        } else if (state is AuthFailure) {
          DialogHelper.showErrorDialog(context, title: 'Registration Failed', message: state.message);
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF6366F1)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: const Icon(Icons.person_add_rounded, size: 32, color: AppColors.primary),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Join AppointEase',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Create your account',
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: 28),

                    // Register Card
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 440),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 40,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'Create Account',
                                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Center(
                              child: Text(
                                'Fill in the details to get started',
                                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Role selector
                            Text(
                              'I AM A',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark, letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 8),
                            RoleSelectorWidget(
                              selectedRole: _selectedRole,
                              onRoleChanged: (role) => setState(() => _selectedRole = role),
                            ),
                            const SizedBox(height: 18),

                            AuthTextField(
                              label: 'FULL NAME',
                              hintText: 'John Doe',
                              controller: _fullNameCtrl,
                              prefixIcon: const Icon(Icons.person_outline_rounded, size: 20, color: AppColors.textHint),
                              validator: (v) => v == null || v.isEmpty ? 'Full name is required' : null,
                            ),
                            const SizedBox(height: 14),
                            AuthTextField(
                              label: 'EMAIL',
                              hintText: 'you@example.com',
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20, color: AppColors.textHint),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Email is required';
                                if (!v.contains('@')) return 'Enter a valid email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            AuthTextField(
                              label: 'PHONE',
                              hintText: '+63 912 345 6789',
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: AppColors.textHint),
                              validator: (v) => v == null || v.isEmpty ? 'Phone number is required' : null,
                            ),
                            const SizedBox(height: 14),

                            if (_selectedRole == 'faculty') ...[
                              AuthTextField(
                                label: 'DEPARTMENT',
                                hintText: 'e.g. Computer Science',
                                controller: _departmentCtrl,
                                prefixIcon: const Icon(Icons.business_outlined, size: 20, color: AppColors.textHint),
                                validator: (v) => v == null || v.isEmpty ? 'Department is required' : null,
                              ),
                              const SizedBox(height: 14),
                              AuthTextField(
                                label: 'SPECIALIZATION',
                                hintText: 'e.g. Machine Learning',
                                controller: _specializationCtrl,
                                prefixIcon: const Icon(Icons.science_outlined, size: 20, color: AppColors.textHint),
                                validator: (v) => v == null || v.isEmpty ? 'Specialization is required' : null,
                              ),
                              const SizedBox(height: 14),
                              AuthTextField(
                                label: 'OFFICE',
                                hintText: 'e.g. Room 301',
                                controller: _officeLocationCtrl,
                                prefixIcon: const Icon(Icons.location_on_outlined, size: 20, color: AppColors.textHint),
                                validator: (v) => v == null || v.isEmpty ? 'Office location is required' : null,
                              ),
                              const SizedBox(height: 14),
                            ],
                            if (_selectedRole == 'student') ...[
                              AuthTextField(
                                label: 'STUDENT ID',
                                hintText: 'e.g. 2021-00123',
                                controller: _studentIdCtrl,
                                prefixIcon: const Icon(Icons.badge_outlined, size: 20, color: AppColors.textHint),
                                validator: (v) => v == null || v.isEmpty ? 'Student ID is required' : null,
                              ),
                              const SizedBox(height: 14),
                            ],

                            AuthTextField(
                              label: 'PASSWORD',
                              hintText: 'At least 6 characters',
                              controller: _passwordCtrl,
                              obscureText: _obscurePass,
                              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.textHint),
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _obscurePass = !_obscurePass),
                                icon: Icon(
                                  _obscurePass ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                  size: 20,
                                  color: AppColors.textHint,
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Password is required';
                                if (v.length < 6) return 'Minimum 6 characters';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            AuthTextField(
                              label: 'CONFIRM PASSWORD',
                              hintText: 'Re-enter your password',
                              controller: _confirmPasswordCtrl,
                              obscureText: _obscureConfirmPass,
                              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.textHint),
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
                                icon: Icon(
                                  _obscureConfirmPass ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                  size: 20,
                                  color: AppColors.textHint,
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Please confirm your password';
                                if (v != _passwordCtrl.text) return 'Passwords do not match';
                                return null;
                              },
                            ),
                            const SizedBox(height: 22),

                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _onRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                    : Text(
                                        'Create Account',
                                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.goNamed('login'),
                                    child: Text(
                                      'Sign in',
                                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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