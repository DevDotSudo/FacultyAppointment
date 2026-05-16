import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_text_field.dart';
import '../../domain/entities/user_entity.dart';
import '../../../shared/widgets/dialog_helper.dart';
import '../../../../core/utils/responsive.dart';

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

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await context.read<AuthCubit>().login(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
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
          DialogHelper.showErrorDialog(context, title: 'Login Failed', message: state.message);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= Responsive.tablet;
            if (isWide) {
              return Row(
                children: [
                  Expanded(child: _BrandPanel()),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(48),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: _LoginForm(
                            formKey: _formKey,
                            emailCtrl: _emailCtrl,
                            passwordCtrl: _passwordCtrl,
                            obscurePass: _obscurePass,
                            isLoading: _isLoading,
                            onToggleObscure: () => setState(() => _obscurePass = !_obscurePass),
                            onLogin: _onLogin,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth < Responsive.mobileL ? 16 : 24,
                  vertical: 40,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: _LoginForm(
                    formKey: _formKey,
                    emailCtrl: _emailCtrl,
                    passwordCtrl: _passwordCtrl,
                    obscurePass: _obscurePass,
                    isLoading: _isLoading,
                    onToggleObscure: () => setState(() => _obscurePass = !_obscurePass),
                    onLogin: _onLogin,
                  ),
                ),
              ),
            );
          },
        ),
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
          // Decorative circles
          Positioned(top: -60, left: -60, child: _Circle(200, Colors.white.withValues(alpha: 0.05))),
          Positioned(bottom: -80, right: -80, child: _Circle(300, Colors.white.withValues(alpha: 0.05))),
          Positioned(top: 120, right: -40, child: _Circle(140, Colors.white.withValues(alpha: 0.04))),
          // Content
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
                  Text('Faculty\nAppointment\nSystem',
                    style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
                  const SizedBox(height: 16),
                  Text('Schedule meetings with faculty\nseamlessly and efficiently.',
                    style: GoogleFonts.inter(fontSize: 15, color: Colors.white.withValues(alpha: 0.75), height: 1.6)),
                  const SizedBox(height: 48),
                  ...[
                    ('📅', 'Easy appointment booking'),
                    ('🔔', 'Real-time notifications'),
                    ('📊', 'Track your appointments'),
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

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final bool obscurePass;
  final bool isLoading;
  final VoidCallback onToggleObscure;
  final VoidCallback onLogin;

  const _LoginForm({
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.obscurePass,
    required this.isLoading,
    required this.onToggleObscure,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Welcome back', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 6),
          Text('Sign in to your account to continue', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted)),
          const SizedBox(height: 32),

          AuthTextField(
            label: 'EMAIL ADDRESS',
            hintText: 'you@example.com',
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.mail_outline, size: 18, color: AppColors.textHint),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 16),

          AuthTextField(
            label: 'PASSWORD',
            hintText: 'Enter your password',
            controller: passwordCtrl,
            obscureText: obscurePass,
            prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.textHint),
            suffixIcon: IconButton(
              onPressed: onToggleObscure,
              icon: Icon(obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18, color: AppColors.textHint),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 6) return 'Minimum 6 characters';
              return null;
            },
          ),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(padding: const EdgeInsets.only(top: 6), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: Text('Forgot password?', style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary)),
            ),
          ),
          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Sign In', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text("Don't have an account?", style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => context.goNamed('register'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Create an account', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }
}
