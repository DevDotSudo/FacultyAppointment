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
  void initState() {
    super.initState();
    _passwordCtrl.addListener(() => setState(() {}));
  }

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

  double get _passwordStrength {
    final p = _passwordCtrl.text;
    if (p.isEmpty) return 0;
    double score = 0;
    if (p.length >= 6) score += 0.25;
    if (p.length >= 10) score += 0.15;
    if (RegExp(r'[A-Z]').hasMatch(p)) score += 0.2;
    if (RegExp(r'[0-9]').hasMatch(p)) score += 0.2;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(p)) score += 0.2;
    return score.clamp(0, 1);
  }

  Color get _strengthColor {
    if (_passwordStrength < 0.3) return AppColors.danger;
    if (_passwordStrength < 0.6) return AppColors.statusPending;
    if (_passwordStrength < 0.8) return AppColors.lightInfo;
    return AppColors.statusAccepted;
  }

  String get _strengthLabel {
    if (_passwordStrength == 0) return '';
    if (_passwordStrength < 0.3) return 'Weak';
    if (_passwordStrength < 0.6) return 'Fair';
    if (_passwordStrength < 0.8) return 'Good';
    return 'Strong';
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
    final w = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          final route = state.user.role == UserRole.student
              ? 'student-dashboard'
              : 'faculty-dashboard';
          DialogHelper.showSuccessDialog(
            context,
            title: 'Account Created!',
            message: 'Your account has been created successfully. Welcome aboard!',
            onDismiss: () => context.goNamed(route),
          );
        } else if (state is AuthFailure) {
          DialogHelper.showErrorDialog(context, title: 'Registration failed', message: state.message);
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBg : AppColors.accent, // Emerald background!
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: _buildRegisterCard(w, isDark),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterCard(double w, bool isDark) {
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final accentColor = isDark ? AppColors.accent : AppColors.primary;
    final isMobile = w < 600;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 32 : 40),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo and Title (Flat design)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person_add_alt_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 20),
            Text(
              'Create Account',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Join AppointEase today',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: mutedColor,
              ),
            ),
            const SizedBox(height: 28),

            // Role Selector
            RoleSelectorWidget(
              selectedRole: _selectedRole,
              onRoleChanged: (r) => setState(() => _selectedRole = r),
            ),
            const SizedBox(height: 24),

            // Two-column layout for desktop, single column for mobile
            if (isMobile) ...[
              // Mobile: Single column
              AuthTextField(
                label: 'Full Name',
                hintText: 'Enter your full name',
                controller: _fullNameCtrl,
                prefixIcon: Icon(Icons.person_outline_rounded, size: 18, color: accentColor),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              AuthTextField(
                label: 'Email Address',
                hintText: 'Enter your email',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icon(Icons.email_outlined, size: 18, color: accentColor),
                validator: (v) => v == null || v.isEmpty
                    ? 'Required'
                    : (!v.contains('@') ? 'Invalid email' : null),
              ),
              const SizedBox(height: 14),
              AuthTextField(
                label: 'Phone Number',
                hintText: '+63 912 345 6789',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                prefixIcon: Icon(Icons.phone_outlined, size: 18, color: accentColor),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ] else ...[
              // Desktop: Two columns
              Row(
                children: [
                  Expanded(
                    child: AuthTextField(
                      label: 'Full Name',
                      hintText: 'Enter your full name',
                      controller: _fullNameCtrl,
                      prefixIcon: Icon(Icons.person_outline_rounded, size: 18, color: accentColor),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AuthTextField(
                      label: 'Email Address',
                      hintText: 'Enter your email',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icon(Icons.email_outlined, size: 18, color: accentColor),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Required'
                          : (!v.contains('@') ? 'Invalid email' : null),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AuthTextField(
                label: 'Phone Number',
                hintText: '+63 912 345 6789',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                prefixIcon: Icon(Icons.phone_outlined, size: 18, color: accentColor),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ],

            // Role-specific fields
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _selectedRole == 'faculty'
                  ? _buildFacultyFields(mutedColor, accentColor, isMobile)
                  : _buildStudentFields(mutedColor, accentColor),
            ),

            const SizedBox(height: 14),

            // Password fields in two columns for desktop
            if (isMobile) ...[
              AuthTextField(
                label: 'Password',
                hintText: 'At least 6 characters',
                controller: _passwordCtrl,
                obscureText: _obscurePass,
                prefixIcon: Icon(Icons.lock_outline_rounded, size: 18, color: accentColor),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                  icon: Icon(
                    _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 18,
                    color: mutedColor,
                  ),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? 'Required'
                    : (v.length < 6 ? 'Minimum 6 characters' : null),
              ),
              if (_passwordCtrl.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _passwordStrength,
                    backgroundColor: isDark ? Colors.white12 : Colors.black12,
                    valueColor: AlwaysStoppedAnimation(_strengthColor),
                    minHeight: 3,
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _strengthLabel,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: _strengthColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              AuthTextField(
                label: 'Confirm Password',
                hintText: 'Re-enter your password',
                controller: _confirmPasswordCtrl,
                obscureText: _obscureConfirmPass,
                prefixIcon: Icon(Icons.lock_outline_rounded, size: 18, color: accentColor),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
                  icon: Icon(
                    _obscureConfirmPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 18,
                    color: mutedColor,
                  ),
                ),
                validator: (v) => v != _passwordCtrl.text ? 'Passwords do not match' : null,
              ),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AuthTextField(
                          label: 'Password',
                          hintText: 'At least 6 characters',
                          controller: _passwordCtrl,
                          obscureText: _obscurePass,
                          prefixIcon: Icon(Icons.lock_outline_rounded, size: 18, color: accentColor),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscurePass = !_obscurePass),
                            icon: Icon(
                              _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: 18,
                              color: mutedColor,
                            ),
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Required'
                              : (v.length < 6 ? 'Minimum 6 characters' : null),
                        ),
                        if (_passwordCtrl.text.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _passwordStrength,
                              backgroundColor: isDark ? Colors.white12 : Colors.black12,
                              valueColor: AlwaysStoppedAnimation(_strengthColor),
                              minHeight: 3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _strengthLabel,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: _strengthColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AuthTextField(
                      label: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      controller: _confirmPasswordCtrl,
                      obscureText: _obscureConfirmPass,
                      prefixIcon: Icon(Icons.lock_outline_rounded, size: 18, color: accentColor),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
                        icon: Icon(
                          _obscureConfirmPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 18,
                          color: mutedColor,
                        ),
                      ),
                      validator: (v) => v != _passwordCtrl.text ? 'Passwords do not match' : null,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),

            // Create Account Button (Flat design)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  elevation: 0,  // Flat!
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Create Account',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Sign In Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: mutedColor,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.goNamed('login'),
                  child: Text(
                    'Sign In',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacultyFields(Color mutedColor, Color accentColor, bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          AuthTextField(
            label: 'Department',
            hintText: 'e.g. Computer Science',
            controller: _departmentCtrl,
            prefixIcon: Icon(Icons.business_outlined, size: 18, color: accentColor),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          AuthTextField(
            label: 'Specialization',
            hintText: 'e.g. Machine Learning',
            controller: _specializationCtrl,
            prefixIcon: Icon(Icons.science_outlined, size: 18, color: accentColor),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          AuthTextField(
            label: 'Office Location',
            hintText: 'e.g. Room 301',
            controller: _officeLocationCtrl,
            prefixIcon: Icon(Icons.location_on_outlined, size: 18, color: accentColor),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: AuthTextField(
                label: 'Department',
                hintText: 'e.g. Computer Science',
                controller: _departmentCtrl,
                prefixIcon: Icon(Icons.business_outlined, size: 18, color: accentColor),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AuthTextField(
                label: 'Specialization',
                hintText: 'e.g. Machine Learning',
                controller: _specializationCtrl,
                prefixIcon: Icon(Icons.science_outlined, size: 18, color: accentColor),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        AuthTextField(
          label: 'Office Location',
          hintText: 'e.g. Room 301',
          controller: _officeLocationCtrl,
          prefixIcon: Icon(Icons.location_on_outlined, size: 18, color: accentColor),
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildStudentFields(Color mutedColor, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        AuthTextField(
          label: 'Student ID',
          hintText: 'e.g. 2021-00123',
          controller: _studentIdCtrl,
          prefixIcon: Icon(Icons.badge_outlined, size: 18, color: accentColor),
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }
}