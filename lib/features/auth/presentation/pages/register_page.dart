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

  // Faculty-only
  final _departmentCtrl = TextEditingController();
  final _specializationCtrl = TextEditingController();
  final _officeLocationCtrl = TextEditingController();

  // Student-only
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
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
          role: _selectedRole,
          fullName: _fullNameCtrl.text,
          phone: _phoneCtrl.text,
          // Faculty
          department: _selectedRole == 'faculty' ? _departmentCtrl.text : null,
          specialization:
              _selectedRole == 'faculty' ? _specializationCtrl.text : null,
          officeLocation:
              _selectedRole == 'faculty' ? _officeLocationCtrl.text : null,
          // Student
          studentId: _selectedRole == 'student' ? _studentIdCtrl.text : null,
        );
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          if (state.user.role == UserRole.student) {
            context.goNamed('student-dashboard');
          } else if (state.user.role == UserRole.faculty) {
            context.goNamed('faculty-dashboard');
          }
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.lightGrayBg,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      'Register',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Create Account',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Role
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Join as',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    RoleSelectorWidget(
                      selectedRole: _selectedRole,
                      onRoleChanged: (role) =>
                          setState(() => _selectedRole = role),
                    ),
                    const SizedBox(height: 12),

                    // Full Name
                    AuthTextField(
                      label: 'Full Name',
                      hintText: 'John Doe',
                      controller: _fullNameCtrl,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Full name is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Email
                    AuthTextField(
                      label: 'Email',
                      hintText: 'you@example.com',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Phone
                    AuthTextField(
                      label: 'Phone',
                      hintText: '+63 912 345 6789',
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Phone number is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Role-specific fields
                    if (_selectedRole == 'faculty') ...[
                      AuthTextField(
                        label: 'Department',
                        hintText: 'e.g. Computer Science',
                        controller: _departmentCtrl,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Department is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      AuthTextField(
                        label: 'Specialization',
                        hintText: 'e.g. Machine Learning',
                        controller: _specializationCtrl,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Specialization is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      AuthTextField(
                        label: 'Office Location',
                        hintText: 'e.g. Room 301, Engineering Bldg',
                        controller: _officeLocationCtrl,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Office location is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (_selectedRole == 'student') ...[
                      AuthTextField(
                        label: 'Student ID',
                        hintText: 'e.g. 2021-00123',
                        controller: _studentIdCtrl,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Student ID is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Password
                    AuthTextField(
                      label: 'Password',
                      hintText: 'Enter your password',
                      controller: _passwordCtrl,
                      obscureText: _obscurePass,
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _obscurePass = !_obscurePass),
                        icon: Icon(
                          _obscurePass
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
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
                    const SizedBox(height: 10),

                    // Confirm Password
                    AuthTextField(
                      label: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      controller: _confirmPasswordCtrl,
                      obscureText: _obscureConfirmPass,
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                            () => _obscureConfirmPass = !_obscureConfirmPass),
                        icon: Icon(
                          _obscureConfirmPass
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
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
                    const SizedBox(height: 20),

                    // Register button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          disabledBackgroundColor:
                              AppColors.primaryBlue.withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Register'),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Login redirect
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: AppColors.textMuted),
                        ),
                        TextButton(
                          onPressed: () => context.goNamed('login'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Login',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ],
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