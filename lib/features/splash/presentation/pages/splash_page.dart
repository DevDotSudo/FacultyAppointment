import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/splash_cubit.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Trigger auth check after build to avoid calling during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SplashCubit>().checkAuthStatus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is SplashNavigateToLogin) {
          context.goNamed('login');
        } else if (state is SplashNavigateToStudentDashboard) {
          context.goNamed('student-dashboard');
        } else if (state is SplashNavigateToFacultyDashboard) {
          context.goNamed('faculty-dashboard');
        }
      },
      child: const Scaffold(
        backgroundColor: AppColors.darkNavy,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_month, size: 64, color: AppColors.primaryBlue),
              SizedBox(height: 16),
              _SplashText(
                text: 'Appointment System',
                size: 24,
                weight: FontWeight.bold,
                color: Colors.white,
              ),
              SizedBox(height: 8),
              _SplashText(
                text: 'Connecting students and faculty',
                size: 14,
                weight: FontWeight.normal,
                color: AppColors.textMuted,
              ),
              SizedBox(height: 32),
              CircularProgressIndicator(
                color: AppColors.primaryBlue,
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashText extends StatelessWidget {
  final String text;
  final double size;
  final FontWeight weight;
  final Color color;

  const _SplashText({
    required this.text,
    required this.size,
    required this.weight,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
      ),
    );
  }
}