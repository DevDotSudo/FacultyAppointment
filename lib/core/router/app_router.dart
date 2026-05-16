import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/injection.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/student/presentation/cubit/student_cubit.dart';
import '../../features/student/presentation/pages/student_dashboard_page.dart';
import '../../features/student/presentation/pages/my_appointments_page.dart';
import '../../features/student/presentation/pages/book_appointment_page.dart';
import '../../features/student/presentation/pages/faculty_list_page.dart';
import '../../features/student/presentation/pages/appointment_detail_page.dart';
import '../../features/student/presentation/pages/student_profile_page.dart';
import '../../features/faculty/presentation/cubit/faculty_cubit.dart';
import '../../features/faculty/presentation/pages/faculty_dashboard_page.dart';
import '../../features/faculty/presentation/pages/appointment_requests_page.dart';
import '../../features/faculty/presentation/pages/manage_availability_page.dart';
import '../../features/faculty/presentation/pages/faculty_profile_page.dart';
import '../../features/faculty/presentation/pages/request_detail_page.dart';
import '../../features/shared/widgets/app_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ── Splash (no sidebar) ─────────────────────────────
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) =>
          BlocProvider(create: (_) => SplashCubit(), child: const SplashPage()),
    ),

    // ── Auth (no sidebar) ────────────────────────────────
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => BlocProvider(
        create: (_) => AuthCubit(
          loginUseCase: sl(),
          registerUseCase: sl(),
          logoutUseCase: sl(),
        ),
        child: const LoginPage(),
      ),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => BlocProvider(
        create: (_) => AuthCubit(
          loginUseCase: sl(),
          registerUseCase: sl(),
          logoutUseCase: sl(),
        ),
        child: const RegisterPage(),
      ),
    ),

    // ── Authenticated routes (with persistent sidebar) ──
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        // ── Student ─────────────────────────────────────
        GoRoute(
          path: '/student/dashboard',
          name: 'student-dashboard',
          builder: (context, state) => BlocProvider(
            create: (_) => sl<StudentCubit>()..loadDashboard(),
            child: const StudentDashboardPage(),
          ),
        ),
        GoRoute(
          path: '/student/my-appointments',
          name: 'student-my-appointments',
          builder: (context, state) => BlocProvider(
            create: (_) => sl<StudentCubit>()..loadDashboard(),
            child: const MyAppointmentsPage(),
          ),
        ),
        GoRoute(
          path: '/student/book-appointment',
          name: 'student-book-appointment',
          builder: (context, state) => BlocProvider(
            create: (_) => sl<StudentCubit>()..loadDashboard(),
            child: const BookAppointmentPage(),
          ),
        ),
        GoRoute(
          path: '/student/faculty',
          name: 'student-faculty',
          builder: (context, state) => BlocProvider(
            create: (_) => sl<StudentCubit>()..loadDashboard(),
            child: const FacultyListPage(),
          ),
        ),
        GoRoute(
          path: '/student/appointment-detail',
          name: 'student-appointment-detail',
          builder: (context, state) => BlocProvider(
            create: (_) => sl<StudentCubit>()..loadDashboard(),
            child: const AppointmentDetailPage(),
          ),
        ),
        GoRoute(
          path: '/student/profile',
          name: 'student-profile',
          builder: (context, state) => BlocProvider(
            create: (_) => sl<StudentCubit>()..loadDashboard(),
            child: const StudentProfilePage(),
          ),
        ),

        // ── Faculty ─────────────────────────────────────
        GoRoute(
          path: '/faculty/dashboard',
          name: 'faculty-dashboard',
          builder: (context, state) => BlocProvider(
            create: (_) => sl<FacultyCubit>()..loadDashboard(),
            child: const FacultyDashboardPage(),
          ),
        ),
        GoRoute(
          path: '/faculty/requests',
          name: 'faculty-requests',
          builder: (context, state) => BlocProvider(
            create: (_) => sl<FacultyCubit>()..loadDashboard(),
            child: const AppointmentRequestsPage(),
          ),
        ),
        GoRoute(
          path: '/faculty/availability',
          name: 'faculty-availability',
          builder: (context, state) => BlocProvider(
            create: (_) => sl<FacultyCubit>()..loadDashboard(),
            child: const ManageAvailabilityPage(),
          ),
        ),
        GoRoute(
          path: '/faculty/profile',
          name: 'faculty-profile',
          builder: (context, state) => BlocProvider(
            create: (_) => sl<FacultyCubit>()..loadDashboard(),
            child: const FacultyProfilePage(),
          ),
        ),
        GoRoute(
          path: '/faculty/request-detail',
          name: 'faculty-request-detail',
          builder: (context, state) => BlocProvider(
            create: (_) => sl<FacultyCubit>()..loadDashboard(),
            child: const RequestDetailPage(),
          ),
        ),
      ],
    ),
  ],
);