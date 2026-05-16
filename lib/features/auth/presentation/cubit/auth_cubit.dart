import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_state.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../data/datasources/auth_remote_datasource.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       _logoutUseCase = logoutUseCase,
       super(AuthInitial());

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      await _loginUseCase(email: email, password: password);
      final user = AuthRemoteDatasource().getCurrentUser();
      if (user == null) {
        emit(AuthFailure('Authentication failed. Please try again'));
        return;
      }
      // Read role from Firestore
      final roleString = await AuthRemoteDatasource().getUserRole(user.uid);
      if (roleString == null) {
        emit(AuthFailure('Unable to determine user role'));
        return;
      }
      final role = roleString == 'student' ? UserRole.student : UserRole.faculty;
      emit(AuthSuccess(UserEntity(id: user.uid, email: user.email ?? email, role: role)));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> registerUser({
    required String email,
    required String password,
    required String role,
    required String fullName,
    required String phone,
    // Faculty-only
    String? department,
    String? specialization,
    String? officeLocation,
    // Student-only
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
      final user = AuthRemoteDatasource().getCurrentUser();
      if (user == null) {
        emit(AuthFailure('Registration failed'));
        return;
      }
      final roleEnum = role == 'student' ? UserRole.student : UserRole.faculty;
      emit(AuthSuccess(UserEntity(id: user.uid, email: email, role: roleEnum)));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> logout() async {
    await _logoutUseCase.call();
    emit(AuthInitial());
  }
}