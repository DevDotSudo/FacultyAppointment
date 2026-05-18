import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_text_field.dart';
import '../../domain/entities/user_entity.dart';
import '../../../shared/widgets/dialog_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

  Future<void> _loadRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('remembered_email') ?? '';
    final password = prefs.getString('remembered_password') ?? '';
    final remember = prefs.getBool('remember_me') ?? false;
    if (mounted) {
      setState(() {
        _rememberMe = remember;
        if (remember) {
          _emailCtrl.text = email;
          _passwordCtrl.text = password;
        }
      });
    }
  }

  Future<void> _saveRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('remembered_email', _emailCtrl.text.trim());
      await prefs.setString('remembered_password', _passwordCtrl.text);
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('remembered_email');
      await prefs.remove('remembered_password');
      await prefs.setBool('remember_me', false);
    }
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await _saveRememberedCredentials();
    await context.read<AuthCubit>().login(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
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
          if (state.user.role == UserRole.student) {
            context.goNamed('student-dashboard');
          } else {
            context.goNamed('faculty-dashboard');
          }
        } else if (state is AuthFailure) {
          DialogHelper.showErrorDialog(context, title: 'Sign in failed', message: state.message);
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: 400,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF8B5CF6)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(height: 16),
                    Text('Sign in to AppointEase',
                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: textColor)),
                    const SizedBox(height: 4),
                    Text('Enter your credentials to continue',
                      style: GoogleFonts.inter(fontSize: 14, color: mutedColor)),
                    const SizedBox(height: 24),

                    AuthTextField(
                      label: 'Email',
                      hintText: 'you@example.com',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.mail_outline_rounded, size: 18, color: AppColors.textHint),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    AuthTextField(
                      label: 'Password',
                      hintText: 'Enter your password',
                      controller: _passwordCtrl,
                      obscureText: _obscurePass,
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.textHint),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscurePass = !_obscurePass),
                        icon: Icon(
                          _obscurePass ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          size: 18, color: AppColors.textHint,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password is required';
                        if (v.length < 6) return 'Minimum 6 characters';
                        return null;
                      },
                    ),

                    // Remember Me + Forgot Password row
                    Row(
                      children: [
                        SizedBox(
                          height: 40,
                          child: InkWell(
                            onTap: () => setState(() => _rememberMe = !_rememberMe),
                            borderRadius: BorderRadius.circular(4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 20, height: 20,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (v) => setState(() => _rememberMe = v ?? false),
                                    activeColor: AppColors.primary,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text('Remember me',
                                  style: GoogleFonts.inter(fontSize: 13, color: mutedColor)),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: Text('Forgot password?',
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onLogin,
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text('Sign in', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(child: Divider(color: borderColor)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text("Don't have an account?",
                            style: GoogleFonts.inter(fontSize: 13, color: mutedColor)),
                        ),
                        Expanded(child: Divider(color: borderColor)),
                      ],
                    ),
                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => context.goNamed('register'),
                        child: Text('Create an account',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
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