import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_text_field.dart';
import '../../domain/entities/user_entity.dart';

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
    try {
      context.read<AuthCubit>().login(
            email: _emailCtrl.text,
            password: _passwordCtrl.text,
          );
    } catch (e) {
      // Error handled by cubit
    }
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
        backgroundColor: AppColors.pageBackground,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 980;
            final cardMaxWidth = 420.0;

            if (isWide) {
              final maxW = constraints.maxWidth - 64;
              final width = maxW.clamp(0.0, 900.0);
              return Center(
                child: Container(
                  width: width,
                  height: 520,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildLeftHalf()),
                      Expanded(child: _buildFormCard()),
                    ],
                  ),
                ),
              );
            } else {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: cardMaxWidth),
                    child: _buildFormCard(),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // ── LEFT HALF: ILLUSTRATION ──────────────────────────
  Widget _buildLeftHalf() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.primaryBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIllustration(),
          const SizedBox(height: 24),
          const Text(
            'Faculty Appointment Portal',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Access your appointments, schedules, and profile in one secure place.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ── ILLUSTRATION WIDGET ────────────────────────────────
  Widget _buildIllustration() {
    return SizedBox(
      width: 220,
      height: 180,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Shadow base ellipse under desk
          Positioned(
            bottom: 0,
            left: 20,
            right: 20,
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(191, 219, 254, 0.6),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),

          // Left plant
          Positioned(left: 0, bottom: 8, child: _buildPlant()),

          // Right plant (mirrored)
          Positioned(
            right: 0,
            bottom: 8,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14159),
              child: _buildPlant(),
            ),
          ),

          // Desk surface
          Positioned(
            left: 36,
            right: 36,
            bottom: 8,
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF93C5FD),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Desk legs
          Positioned(
            left: 52,
            bottom: 0,
            child: Container(
              width: 8,
              height: 10,
              color: const Color(0xFF60A5FA),
            ),
          ),
          Positioned(
            right: 52,
            bottom: 0,
            child: Container(
              width: 8,
              height: 10,
              color: const Color(0xFF60A5FA),
            ),
          ),

          // Calendar on desk
          Positioned(left: 50, bottom: 18, child: _buildCalendar()),

          // Person
          Positioned(right: 52, bottom: 18, child: _buildPerson()),

          // Decorative dots top-left
          Positioned(top: 16, left: 24, child: _buildDotCluster()),

          // Decorative dots top-right
          Positioned(top: 8, right: 24, child: _buildDotCluster()),
        ],
      ),
    );
  }

  Widget _buildPlant() {
    return SizedBox(
      width: 36,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 56,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Transform.rotate(
                    angle: -0.4,
                    child: _buildLeaf(
                      color: const Color(0xFF34D399),
                      width: 14,
                      height: 28,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 10,
                  child: _buildLeaf(
                    color: const Color(0xFF10B981),
                    width: 14,
                    height: 40,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Transform.rotate(
                    angle: 0.4,
                    child: _buildLeaf(
                      color: const Color(0xFF34D399),
                      width: 14,
                      height: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 28,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF60A5FA),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
          ),
          Container(
            width: 32,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaf({
    required Color color,
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(2),
          bottomLeft: Radius.circular(2),
          bottomRight: Radius.circular(8),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      width: 64,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
            ),
            child: const Center(
              child: Text(
                'MAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                children: List.generate(8, (i) {
                  final highlighted = i == 3;
                  return Container(
                    decoration: BoxDecoration(
                      color: highlighted
                          ? const Color(0xFF2563EB)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.w500,
                          color: highlighted
                              ? Colors.white
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerson() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: Color(0xFFFBBF24),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('😊', style: TextStyle(fontSize: 13)),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 32,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _buildDotCluster() {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: List.generate(4, (i) {
        return Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(147, 197, 253, 0.7),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  // ── RIGHT: FORM CARD ───────────────────────────────────
  Widget _buildFormCard() {
    return Card(
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title + subtitle
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Login',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Welcome back, please sign in',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

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

              const SizedBox(height: 18),

              // Password
              AuthTextField(
                label: 'Password',
                hintText: 'Enter your password',
                controller: _passwordCtrl,
                obscureText: _obscurePass,
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                  icon: Icon(
                    _obscurePass
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required';
                  if (v.length < 6) return 'Minimum 6 characters';
                  return null;
                },
              ),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(top: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(fontSize: 13, color: AppColors.primary),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: const Color.fromRGBO(
                      37,
                      99,
                      235,
                      0.6,
                    ),
                    elevation: 0,
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
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Register redirect
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  GestureDetector(
                    onTap: () => context.goNamed('register'),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
