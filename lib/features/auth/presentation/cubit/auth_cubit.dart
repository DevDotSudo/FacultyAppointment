import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_state.dart';
import '../../domain/entities/user_entity.dart';
import '../../data/datasources/auth_remote_datasource.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRemoteDatasource _remoteDatasource;
  AuthCubit(this._remoteDatasource) : super(AuthInitial());

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final cred = await _remoteDatasource.signIn(email: email, password: password);
      final user = cred.user;
      if (user == null) {
        emit(AuthFailure('Authentication failed. Please try again'));
        return;
      }
      String? roleValue;
      final studentDoc = await FirebaseFirestore.instance.collection('students').doc(user.uid).get();
      if (studentDoc.exists) {
        roleValue = 'student';
      } else {
        final facultyDoc = await FirebaseFirestore.instance.collection('faculty').doc(user.uid).get();
        if (facultyDoc.exists) roleValue = 'faculty';
      }
      if (roleValue == null) {
        emit(AuthFailure('Unable to determine user role'));
        return;
      }
      final role = roleValue == 'student' ? UserRole.student : UserRole.faculty;
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
      final cred = await _remoteDatasource.signUp(email: email, password: password);
      final user = cred.user;
      if (user == null) {
        emit(AuthFailure('Registration failed'));
        return;
      }
      await _remoteDatasource.insertUserProfile(
        id: user.uid,
        role: role,
        fullName: fullName,
        email: email,
        phone: phone,
        department: department,
        specialization: specialization,
        officeLocation: officeLocation,
        studentId: studentId,
      );
      final roleEnum = role == 'student' ? UserRole.student : UserRole.faculty;
      emit(AuthSuccess(UserEntity(id: user.uid, email: email, role: roleEnum)));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}