import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:faculty_appointment/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:faculty_appointment/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:faculty_appointment/features/auth/domain/usecases/login_usecase.dart';
import 'package:faculty_appointment/features/auth/domain/usecases/register_usecase.dart';
import 'package:faculty_appointment/features/auth/domain/usecases/logout_usecase.dart';
import 'package:faculty_appointment/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:faculty_appointment/features/splash/presentation/cubit/splash_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => AuthRemoteDatasource());
  sl.registerLazySingleton(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerFactory(() => AuthCubit(sl()));
  sl.registerFactory(() => SplashCubit());
}
