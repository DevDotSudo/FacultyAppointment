import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splash_state.dart';
export 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  Future<void> checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        emit(SplashNavigateToLogin());
        return;
      }

      // If remember_me is false, sign out and go to login
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool('remember_me') ?? false;
      if (!rememberMe) {
        await FirebaseAuth.instance.signOut();
        emit(SplashNavigateToLogin());
        return;
      }

      // Determine role
      final studentDoc = await FirebaseFirestore.instance
          .collection('students').doc(user.uid).get();
      if (studentDoc.exists) {
        emit(SplashNavigateToStudentDashboard());
        return;
      }

      final facultyDoc = await FirebaseFirestore.instance
          .collection('faculty').doc(user.uid).get();
      if (facultyDoc.exists) {
        emit(SplashNavigateToFacultyDashboard());
        return;
      }

      // Role not found — sign out
      await FirebaseAuth.instance.signOut();
      emit(SplashNavigateToLogin());
    } catch (_) {
      emit(SplashNavigateToLogin());
    }
  }
}
