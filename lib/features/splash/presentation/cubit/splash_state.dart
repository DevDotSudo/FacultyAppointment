part of 'splash_cubit.dart';

sealed class SplashState {}

class SplashInitial extends SplashState {}

class SplashNavigateToLogin extends SplashState {}

class SplashNavigateToStudentDashboard extends SplashState {}

class SplashNavigateToFacultyDashboard extends SplashState {}
