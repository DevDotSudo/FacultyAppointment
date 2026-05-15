import 'package:faculty_appointment/features/auth/data/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;

  AuthRepositoryImpl(this._remoteDatasource);

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await _remoteDatasource.signIn(
      email: email,
      password: password,
    );

    final uid = response.user!.uid;
    String? roleValue;
    final studentDoc = await FirebaseFirestore.instance.collection('students').doc(uid).get();
    if (studentDoc.exists) {
      roleValue = 'student';
    } else {
      final facultyDoc = await FirebaseFirestore.instance.collection('faculty').doc(uid).get();
      if (facultyDoc.exists) roleValue = 'faculty';
    }
    if (roleValue == null) throw Exception('Unable to determine user role');
  }

  @override
  Future<void> register({
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
    final response = await _remoteDatasource.signUp(
      email: email,
      password: password,
    );

    await _remoteDatasource.insertUserProfile(
      id: response.user!.uid,
      role: role,
      fullName: fullName,
      email: email,
      phone: phone,
      department: department,
      specialization: specialization,
      officeLocation: officeLocation,
      studentId: studentId,
    );
  }

  @override
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}