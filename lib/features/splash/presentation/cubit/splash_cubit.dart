import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  Future<void> checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(SplashNavigateToLogin());
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
        emit(SplashNavigateToLogin());
        return;
      }

      if (roleValue == 'student') {
        emit(SplashNavigateToStudentDashboard());
      } else if (roleValue == 'faculty') {
        emit(SplashNavigateToFacultyDashboard());
      } else {
        emit(SplashNavigateToLogin());
      }
    } catch (e) {
      emit(SplashNavigateToLogin());
    }
  }
}
