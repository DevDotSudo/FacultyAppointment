import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../pages/student_dashboard_page.dart';

class StudentCubit extends Cubit<StudentState> {
  StudentCubit() : super(StudentInitial());

  void loadDashboard() async {
    emit(StudentLoading());
    // Simulated data - will be replaced with real Supabase calls
    await Future.delayed(const Duration(seconds: 1));
    emit(StudentLoaded(
      totalAppointments: 12,
      pending: 3,
      accepted: 7,
      rejected: 2,
      upcomingAppointments: [
        UpcomingAppointmentData(
          facultyName: 'Dr. Maria Santos',
          facultyInitials: 'MS',
          date: 'May 20, 2026',
          time: '10:00 AM',
          purpose: 'Academic advising for thesis',
          status: 'Pending',
        ),
      ],
    ));
  }
}

sealed class StudentState {}

class StudentInitial extends StudentState {}

class StudentLoading extends StudentState {}

class StudentLoaded extends StudentState {
  final int totalAppointments;
  final int pending;
  final int accepted;
  final int rejected;
  final List<UpcomingAppointmentData> upcomingAppointments;

  const StudentLoaded({
    required this.totalAppointments,
    required this.pending,
    required this.accepted,
    required this.rejected,
    required this.upcomingAppointments,
  });
}

class StudentError extends StudentState {
  final String message;
  StudentError(this.message);
}

class UpcomingAppointmentData {
  final String facultyName;
  final String facultyInitials;
  final String date;
  final String time;
  final String purpose;
  final String status;

  UpcomingAppointmentData({
    required this.facultyName,
    required this.facultyInitials,
    required this.date,
    required this.time,
    required this.purpose,
    required this.status,
  });
}
