import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/injection.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/student/presentation/pages/student_dashboard_page.dart';
import '../../features/faculty/presentation/pages/faculty_dashboard_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [

    // ── Splash ──────────────────────────────────────────
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => BlocProvider(
        create: (_) => SplashCubit(),
        child: const SplashPage(),
      ),
    ),

    // ── Auth ─────────────────────────────────────────────
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => BlocProvider(
        create: (_) => AuthCubit(sl()),
        child: const LoginPage(),
      ),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => BlocProvider(
        create: (_) => AuthCubit(sl()),
        child: const RegisterPage(),
      ),
    ),

    GoRoute(
      path: '/student/dashboard',
      name: 'student-dashboard',
      builder: (context, state) => const StudentDashboardPage(),
    ),

    // ── Faculty ───────────────────────────────────────────
    GoRoute(
      path: '/faculty/dashboard',
      name: 'faculty-dashboard',
      builder: (context, state) => const FacultyDashboardPage(),
    ),

  ],
);