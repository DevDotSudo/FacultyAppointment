import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:faculty_appointment/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:faculty_appointment/features/auth/data/repositories/auth_repository.dart';
import 'package:faculty_appointment/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:faculty_appointment/features/auth/domain/usecases/login_usecase.dart';
import 'package:faculty_appointment/features/auth/domain/usecases/register_usecase.dart';
import 'package:faculty_appointment/features/auth/domain/usecases/logout_usecase.dart';
import 'package:faculty_appointment/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:faculty_appointment/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:faculty_appointment/features/student/data/datasources/student_remote_datasource.dart';
import 'package:faculty_appointment/features/student/data/repositories/student_repository_impl.dart';
import 'package:faculty_appointment/features/student/domain/usecases/get_my_appointments_usecase.dart';
import 'package:faculty_appointment/features/student/domain/usecases/get_upcoming_appointments_usecase.dart';
import 'package:faculty_appointment/features/student/domain/usecases/get_faculty_list_usecase.dart';
import 'package:faculty_appointment/features/student/domain/usecases/book_appointment_usecase.dart';
import 'package:faculty_appointment/features/student/domain/usecases/cancel_appointment_usecase.dart';
import 'package:faculty_appointment/features/student/presentation/cubit/student_cubit.dart';
import 'package:faculty_appointment/features/faculty/data/datasources/faculty_remote_datasource.dart';
import 'package:faculty_appointment/features/faculty/data/repositories/faculty_repository_impl.dart';
import 'package:faculty_appointment/features/faculty/domain/usecases/get_appointment_requests_usecase.dart';
import 'package:faculty_appointment/features/faculty/domain/usecases/get_pending_requests_usecase.dart';
import 'package:faculty_appointment/features/faculty/domain/usecases/get_availability_usecase.dart';
import 'package:faculty_appointment/features/faculty/domain/usecases/accept_request_usecase.dart';
import 'package:faculty_appointment/features/faculty/domain/usecases/reject_request_usecase.dart';
import 'package:faculty_appointment/features/faculty/domain/usecases/manage_availability_usecase.dart';
import 'package:faculty_appointment/features/faculty/domain/usecases/update_profile_usecase.dart';
import 'package:faculty_appointment/features/faculty/presentation/cubit/faculty_cubit.dart';
import 'package:faculty_appointment/features/faculty/domain/repositories/faculty_repository.dart';
import 'package:faculty_appointment/features/student/domain/repositories/student_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  try {
    debugPrint('═══ DI: Starting dependency injection ═══');

    // ── Datasources ──
    sl.registerLazySingleton(() => AuthRemoteDatasource());
    sl.registerLazySingleton(() => StudentRemoteDatasource());
    sl.registerLazySingleton(() => FacultyRemoteDatasource());

    // ── Repositories ──
    sl.registerLazySingleton<FacultyRepository>(() => FacultyRepositoryImpl(sl<FacultyRemoteDatasource>()));
    sl.registerLazySingleton<StudentRepository>(() => StudentRepositoryImpl(sl<StudentRemoteDatasource>()));
    sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl<AuthRemoteDatasource>()));

    // ── Auth Use Cases ──
    sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
    sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
    sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));

    // ── Student Use Cases ──
    sl.registerLazySingleton(() => GetMyAppointmentsUseCase(sl<StudentRepository>()));
    sl.registerLazySingleton(() => GetUpcomingAppointmentsUseCase(sl<StudentRepository>()));
    sl.registerLazySingleton(() => GetFacultyListUseCase(sl<StudentRepository>()));
    sl.registerLazySingleton(() => BookAppointmentUseCase());
    sl.registerLazySingleton(() => CancelAppointmentUseCase());

    // ── Faculty Use Cases ──
    sl.registerLazySingleton(() => GetAppointmentRequestsUseCase(sl<FacultyRepository>()));
    sl.registerLazySingleton(() => GetPendingRequestsUseCase(sl<FacultyRepository>()));
    sl.registerLazySingleton(() => GetAvailabilityUseCase(sl<FacultyRepository>()));
    sl.registerLazySingleton(() => AcceptRequestUseCase());
    sl.registerLazySingleton(() => RejectRequestUseCase());
    sl.registerLazySingleton(() => ManageAvailabilityUseCase());
    sl.registerLazySingleton(() => UpdateProfileUseCase());

    // ── Cubits ──
    sl.registerFactory(() => AuthCubit(
      loginUseCase: sl<LoginUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
    ));
    sl.registerFactory(() => SplashCubit());
    sl.registerFactory(() => StudentCubit(sl<GetUpcomingAppointmentsUseCase>(), sl<GetFacultyListUseCase>()));
    sl.registerFactory(() => FacultyCubit(sl<GetPendingRequestsUseCase>(), sl<GetAppointmentRequestsUseCase>()));

    debugPrint('═══ DI: All dependencies registered successfully ═══');
  } catch (e, stackTrace) {
    debugPrint('❌ DI ERROR: Failed to register dependencies: $e');
    debugPrint('❌ Stack trace: $stackTrace');
    rethrow;
  }
}