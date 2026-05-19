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
    final remember = prefs.getBool('remember_me') ?? false;
    final email = prefs.getString('remembered_email') ?? '';
    if (mounted) {
      setState(() {
        _rememberMe = remember;
        if (remember && email.isNotEmpty) _emailCtrl.text = email;
      });
    }
  }

  Future<void> _saveRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('remembered_email', _emailCtrl.text.trim());
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('remembered_email');
      await prefs.setBool('remember_me', false);
    }
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final cubit = context.read<AuthCubit>();
    await _saveRememberedCredentials();
    if (!mounted) return;
    await cubit.login(
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
            title: 'Welcome back!',
            message: 'You have signed in successfully.',
            onDismiss: () => context.goNamed(route),
          );
        } else if (state is AuthFailure) {
          DialogHelper.showErrorDialog(context, title: 'Sign in failed', message: state.message);
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBg : AppColors.primary, // Blue background!
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(w < 360 ? 16 : 24), // Reduce padding on very small screens
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: _buildLoginCard(w, isDark),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(double w, bool isDark) {
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkCardBg : Colors.white;
    
    // Responsive padding for very small screens
    final cardPadding = w < 360 ? 20.0 : 32.0;
    final logoSize = w < 360 ? 56.0 : 64.0;
    final titleSize = w < 360 ? 20.0 : 24.0;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(cardPadding),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo
            Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.calendar_month_rounded, color: Colors.white, size: logoSize * 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome Back',
              style: GoogleFonts.poppins(
                fontSize: titleSize,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to continue to AppointEase',
              style: GoogleFonts.inter(
                fontSize: w < 360 ? 13 : 14,
                color: mutedColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: w < 360 ? 24 : 32),

            // Email Field
            AuthTextField(
              label: 'Email Address',
              hintText: 'Enter your email',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icon(Icons.email_outlined, size: 20, color: AppColors.primary),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            SizedBox(height: w < 360 ? 16 : 20),

            // Password Field
            AuthTextField(
              label: 'Password',
              hintText: 'Enter your password',
              controller: _passwordCtrl,
              obscureText: _obscurePass,
              prefixIcon: Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.primary),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
                icon: Icon(
                  _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                  color: mutedColor,
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 6) return 'Minimum 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Remember Me & Forgot Password
            Row(
              children: [
                Flexible(
                  child: InkWell(
                    onTap: () => setState(() => _rememberMe = !_rememberMe),
                    borderRadius: BorderRadius.circular(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _rememberMe ? AppColors.primary : Colors.transparent,
                            border: Border.all(
                              color: _rememberMe ? AppColors.primary : mutedColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: _rememberMe
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Remember me',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: mutedColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: w < 360 ? 24 : 32),

            // Sign In Button (Flat)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0, // Flat!
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
                        'Sign In',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
            SizedBox(height: w < 360 ? 24 : 32),

            // Divider
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: isDark ? Colors.white24 : Colors.black12,
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: mutedColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: isDark ? Colors.white24 : Colors.black12,
                    thickness: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: w < 360 ? 24 : 32),

            // Sign Up Link
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: mutedColor,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.goNamed('register'),
                  child: Text(
                    'Sign Up',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
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
}