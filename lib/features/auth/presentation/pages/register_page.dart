import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    try {
      context.read<AuthCubit>().registerUser(
            email: _emailCtrl.text,
            password: _passwordCtrl.text,
            role: _selectedRole,
            fullName: _fullNameCtrl.text,
            phone: _phoneCtrl.text,
            // Faculty
            department: _selectedRole == 'faculty' ? _departmentCtrl.text : null,
            specialization: _selectedRole == 'faculty' ? _specializationCtrl.text : null,
            officeLocation: _selectedRole == 'faculty' ? _officeLocationCtrl.text : null,
            // Student
            studentId: _selectedRole == 'student' ? _studentIdCtrl.text : null,
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
                  height: 640,
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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

  // ── LEFT HALF ─────────────────────────────────────────
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
            'Create your account to access appointments, schedules, and profile.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.4),
          ),
        ],
      ),
    );
  }

  // ── RIGHT: FORM CARD ──────────────────────────────────
  Widget _buildFormCard() {
    return Card(
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Title ──
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Create your account',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Role Selector (TOP) ──
              RoleSelectorWidget(
                selectedRole: _selectedRole,
                onRoleChanged: (role) => setState(() => _selectedRole = role),
              ),

              const SizedBox(height: 20),

              // ── Common Fields ──
              AuthTextField(
                label: 'Full Name',
                hintText: 'John Doe',
                controller: _fullNameCtrl,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Full name is required';
                  return null;
                },
              ),

              const SizedBox(height: 16),

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

              const SizedBox(height: 16),

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

              const SizedBox(height: 16),

              // ── Role-specific Fields ──
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
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Specialization',
                  hintText: 'e.g. Machine Learning',
                  controller: _specializationCtrl,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Specialization is required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Office Location',
                  hintText: 'e.g. Room 301, Engineering Bldg',
                  controller: _officeLocationCtrl,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Office location is required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
              ],

              // ── Password ──
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

              const SizedBox(height: 16),

              // ── Confirm Password ──
              AuthTextField(
                label: 'Confirm Password',
                hintText: 'Re-enter your password',
                controller: _confirmPasswordCtrl,
                obscureText: _obscureConfirmPass,
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscureConfirmPass = !_obscureConfirmPass),
                  icon: Icon(
                    _obscureConfirmPass
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please confirm your password';
                  if (v != _passwordCtrl.text) return 'Passwords do not match';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ── Register Button ──
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor:
                        const Color.fromRGBO(37, 99, 235, 0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Login Redirect ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  GestureDetector(
                    onTap: () => context.goNamed('login'),
                    child: const Text(
                      'Login',
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

  // ── ILLUSTRATION (same as LoginPage) ──────────────────
  Widget _buildIllustration() {
    return SizedBox(
      width: 220,
      height: 180,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0, left: 20, right: 20,
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(191, 219, 254, 0.6),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          Positioned(left: 0, bottom: 8, child: _buildPlant()),
          Positioned(
            right: 0, bottom: 8,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14159),
              child: _buildPlant(),
            ),
          ),
          Positioned(
            left: 36, right: 36, bottom: 8,
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF93C5FD),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Positioned(left: 52, bottom: 0,
              child: Container(width: 8, height: 10, color: const Color(0xFF60A5FA))),
          Positioned(right: 52, bottom: 0,
              child: Container(width: 8, height: 10, color: const Color(0xFF60A5FA))),
          Positioned(left: 50, bottom: 18, child: _buildCalendar()),
          Positioned(right: 52, bottom: 18, child: _buildPerson()),
          Positioned(top: 16, left: 24, child: _buildDotCluster()),
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
                  left: 0, bottom: 0,
                  child: Transform.rotate(
                    angle: -0.4,
                    child: _buildLeaf(color: const Color(0xFF34D399), width: 14, height: 28),
                  ),
                ),
                Positioned(
                  bottom: 0, left: 10,
                  child: _buildLeaf(color: const Color(0xFF10B981), width: 14, height: 40),
                ),
                Positioned(
                  right: 0, bottom: 0,
                  child: Transform.rotate(
                    angle: 0.4,
                    child: _buildLeaf(color: const Color(0xFF34D399), width: 14, height: 28),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 28, height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF60A5FA),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
          ),
          Container(
            width: 32, height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaf({required Color color, required double width, required double height}) {
    return Container(
      width: width, height: height,
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
      width: 64, height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 6, offset: const Offset(0, 2),
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
              child: Text('MAR',
                style: TextStyle(
                  color: Colors.white, fontSize: 9,
                  fontWeight: FontWeight.bold, letterSpacing: 1.2,
                )),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: GridView.count(
                crossAxisCount: 4, shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 2, crossAxisSpacing: 2,
                children: List.generate(8, (i) {
                  final highlighted = i == 3;
                  return Container(
                    decoration: BoxDecoration(
                      color: highlighted ? const Color(0xFF2563EB) : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Center(
                      child: Text('${i + 1}',
                        style: TextStyle(
                          fontSize: 7, fontWeight: FontWeight.w500,
                          color: highlighted ? Colors.white : const Color(0xFF9CA3AF),
                        )),
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
          width: 26, height: 26,
          decoration: const BoxDecoration(color: Color(0xFFFBBF24), shape: BoxShape.circle),
          child: const Center(child: Text('😊', style: TextStyle(fontSize: 13))),
        ),
        const SizedBox(height: 2),
        Container(
          width: 32, height: 36,
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
      spacing: 4, runSpacing: 4,
      children: List.generate(4, (i) => Container(
        width: 5, height: 5,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(147, 197, 253, 0.7),
          shape: BoxShape.circle,
        ),
      )),
    );
  }
}