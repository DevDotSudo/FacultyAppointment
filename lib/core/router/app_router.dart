import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/injection.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/student/presentation/pages/student_dashboard_page.dart';
import '../../features/student/presentation/pages/student_placeholder_pages.dart' as student;
import '../../features/faculty/presentation/pages/faculty_dashboard_page.dart';
import '../../features/faculty/presentation/pages/faculty_placeholder_pages.dart' as faculty;

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

    // ── Student ───────────────────────────────────────────
    GoRoute(
      path: '/student/dashboard',
      name: 'student-dashboard',
      builder: (context, state) => const StudentDashboardPage(),
    ),
    GoRoute(
      path: '/student/my-appointments',
      name: 'student-my-appointments',
      builder: (context, state) => const student.MyAppointmentsPage(),
    ),
    GoRoute(
      path: '/student/book-appointment',
      name: 'student-book-appointment',
      builder: (context, state) => const BookAppointmentPage(),
    ),
    GoRoute(
      path: '/student/faculty',
      name: 'student-faculty',
      builder: (context, state) => const student.FacultyListPage(),
    ),
    GoRoute(
      path: '/student/profile',
      name: 'student-profile',
      builder: (context, state) => const student.StudentProfilePage(),
    ),
    GoRoute(
      path: '/student/appointment-detail',
      name: 'student-appointment-detail',
      builder: (context, state) => const student.AppointmentDetailPage(),
    ),
    GoRoute(
      path: '/student/appointment-detail',
      name: 'student-appointment-detail',
      builder: (context, state) => const AppointmentDetailPage(),
    ),

    // ── Faculty ───────────────────────────────────────────
    GoRoute(
      path: '/faculty/dashboard',
      name: 'faculty-dashboard',
      builder: (context, state) => const FacultyDashboardPage(),
    ),
    GoRoute(
      path: '/faculty/requests',
      name: 'faculty-requests',
      builder: (context, state) => const faculty.AppointmentRequestsPage(),
    ),
    GoRoute(
      path: '/faculty/availability',
      name: 'faculty-availability',
      builder: (context, state) => const faculty.ManageAvailabilityPage(),
    ),
    GoRoute(
      path: '/faculty/profile',
      name: 'faculty-profile',
      builder: (context, state) => const faculty.FacultyProfilePage(),
    ),
    GoRoute(
      path: '/faculty/request-detail',
      name: 'faculty-request-detail',
      builder: (context, state) => const faculty.RequestDetailPage(),
    ),
    GoRoute(
      path: '/faculty/requests',
      name: 'faculty-requests',
      builder: (context, state) => const faculty.AppointmentRequestsPage(),
    ),
    GoRoute(
      path: '/faculty/availability',
      name: 'faculty-availability',
      builder: (context, state) => const faculty.ManageAvailabilityPage(),
    ),
    GoRoute(
      path: '/faculty/profile',
      name: 'faculty-profile',
      builder: (context, state) => const faculty.FacultyProfilePage(),
    ),
    GoRoute(
      path: '/faculty/request-detail',
      name: 'faculty-request-detail',
      builder: (context, state) => const faculty.RequestDetailPage(),
    ),
  ],
);
