import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../../../core/constants/app_constants.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final AuthRemoteDatasource _authDatasource;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    AuthRemoteDatasource? authDatasource,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       _logoutUseCase = logoutUseCase,
       _authDatasource = authDatasource ?? AuthRemoteDatasource(),
       super(AuthInitial());

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      await _loginUseCase(email: email, password: password);
      final user = _authDatasource.getCurrentUser();
      if (user == null) {
        emit(AuthFailure(AppConstants.authError));
        return;
      }
      final roleString = await _authDatasource.getUserRole(user.uid);
      if (roleString == null) {
        emit(AuthFailure('Unable to determine user role'));
        return;
      }
      final role = roleString == 'student' ? UserRole.student : UserRole.faculty;
      emit(AuthSuccess(UserEntity(id: user.uid, email: user.email ?? email, role: role)));
    } catch (e) {
      emit(AuthFailure(AppConstants.parseError(e)));
    }
  }

  Future<void> registerUser({
    required String email,
    required String password,
    required String role,
    required String fullName,
    required String phone,
    String? department,
    String? specialization,
    String? officeLocation,
    String? studentId,
  }) async {
    emit(AuthLoading());
    try {
      await _registerUseCase(
        email: email,
        password: password,
        role: role,
        fullName: fullName,
        phone: phone,
        department: department,
        specialization: specialization,
        officeLocation: officeLocation,
        studentId: studentId,
      );
      final user = _authDatasource.getCurrentUser();
      if (user == null) {
        emit(AuthFailure('Registration failed. Please try again.'));
        return;
      }
      final roleEnum = role == 'student' ? UserRole.student : UserRole.faculty;
      emit(AuthSuccess(UserEntity(id: user.uid, email: email, role: roleEnum)));
    } catch (e) {
      emit(AuthFailure(AppConstants.parseError(e)));
    }
  }

  Future<void> logout() async {
    try {
      await _logoutUseCase.call();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure(AppConstants.parseError(e)));
    }
  }
}