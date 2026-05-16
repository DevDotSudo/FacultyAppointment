import 'package:faculty_appointment/features/student/domain/entities/upcoming_appointment_data.dart';
import 'package:faculty_appointment/features/student/domain/entities/faculty_data.dart';

sealed class StudentState {}

class StudentInitial extends StudentState {}

class StudentLoading extends StudentState {}

class StudentLoaded extends StudentState {
  final int totalAppointments;
  final int pending;
  final int accepted;
  final int rejected;
  final List<UpcomingAppointmentData> upcomingAppointments;
  final List<FacultyData> facultyList;

  StudentLoaded({
    required this.totalAppointments,
    required this.pending,
    required this.accepted,
    required this.rejected,
    required this.upcomingAppointments,
    required this.facultyList,
  });
}

class StudentError extends StudentState {
  final String message;
  StudentError(this.message);
}