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
        backgroundColor: const Color(0xFFF0F2F5),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            final form = _buildForm();
            if (isWide) {
              return Row(
                children: [
                  Expanded(child: _BrandPanel()),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: form,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: form,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Create account', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 6),
          Text('Fill in the details below to get started', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted)),
          const SizedBox(height: 24),

          // Role selector
          Text('I AM A', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark, letterSpacing: 0.3)),
          const SizedBox(height: 8),
          RoleSelectorWidget(
            selectedRole: _selectedRole,
            onRoleChanged: (role) => setState(() => _selectedRole = role),
          ),
          const SizedBox(height: 20),

          // Common fields
          AuthTextField(
            label: 'FULL NAME',
            hintText: 'John Doe',
            controller: _fullNameCtrl,
            prefixIcon: const Icon(Icons.person_outline, size: 18, color: AppColors.textHint),
            validator: (v) => v == null || v.isEmpty ? 'Full name is required' : null,
          ),
          const SizedBox(height: 14),
          AuthTextField(
            label: 'EMAIL ADDRESS',
            hintText: 'you@example.com',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.mail_outline, size: 18, color: AppColors.textHint),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 14),
          AuthTextField(
            label: 'PHONE NUMBER',
            hintText: '+63 912 345 6789',
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone_outlined, size: 18, color: AppColors.textHint),
            validator: (v) => v == null || v.isEmpty ? 'Phone number is required' : null,
          ),
          const SizedBox(height: 14),

          // Role-specific fields
          if (_selectedRole == 'faculty') ...[
            AuthTextField(
              label: 'DEPARTMENT',
              hintText: 'e.g. Computer Science',
              controller: _departmentCtrl,
              prefixIcon: const Icon(Icons.business_outlined, size: 18, color: AppColors.textHint),
              validator: (v) => v == null || v.isEmpty ? 'Department is required' : null,
            ),
            const SizedBox(height: 14),
            AuthTextField(
              label: 'SPECIALIZATION',
              hintText: 'e.g. Machine Learning',
              controller: _specializationCtrl,
              prefixIcon: const Icon(Icons.science_outlined, size: 18, color: AppColors.textHint),
              validator: (v) => v == null || v.isEmpty ? 'Specialization is required' : null,
            ),
            const SizedBox(height: 14),
            AuthTextField(
              label: 'OFFICE LOCATION',
              hintText: 'e.g. Room 301, Engineering Bldg',
              controller: _officeLocationCtrl,
              prefixIcon: const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textHint),
              validator: (v) => v == null || v.isEmpty ? 'Office location is required' : null,
            ),
            const SizedBox(height: 14),
          ],
          if (_selectedRole == 'student') ...[
            AuthTextField(
              label: 'STUDENT ID',
              hintText: 'e.g. 2021-00123',
              controller: _studentIdCtrl,
              prefixIcon: const Icon(Icons.badge_outlined, size: 18, color: AppColors.textHint),
              validator: (v) => v == null || v.isEmpty ? 'Student ID is required' : null,
            ),
            const SizedBox(height: 14),
          ],

          AuthTextField(
            label: 'PASSWORD',
            hintText: 'At least 6 characters',
            controller: _passwordCtrl,
            obscureText: _obscurePass,
            prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.textHint),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscurePass = !_obscurePass),
              icon: Icon(_obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: AppColors.textHint),
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
            prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.textHint),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
              icon: Icon(_obscureConfirmPass ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: AppColors.textHint),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm your password';
              if (v != _passwordCtrl.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _onRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Create Account', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Already have an account? ', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
              GestureDetector(
                onTap: () => context.goNamed('login'),
                child: Text('Sign in', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -60, left: -60, child: _Circle(200, Colors.white.withValues(alpha: 0.05))),
          Positioned(bottom: -80, right: -80, child: _Circle(300, Colors.white.withValues(alpha: 0.05))),
          Positioned(top: 120, right: -40, child: _Circle(140, Colors.white.withValues(alpha: 0.04))),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.calendar_month_rounded, size: 36, color: Colors.white),
                  ),
                  const SizedBox(height: 32),
                  Text('Join the\nAppointment\nSystem',
                    style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
                  const SizedBox(height: 16),
                  Text('Connect with faculty and manage\nyour appointments with ease.',
                    style: GoogleFonts.inter(fontSize: 15, color: Colors.white.withValues(alpha: 0.75), height: 1.6)),
                  const SizedBox(height: 48),
                  ...[
                    ('🎓', 'For students & faculty'),
                    ('⚡', 'Quick & easy setup'),
                    ('🔒', 'Secure & private'),
                  ].map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(children: [
                      Text(item.$1, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 12),
                      Text(item.$2, style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.85))),
                    ]),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final Color color;
  const _Circle(this.size, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
