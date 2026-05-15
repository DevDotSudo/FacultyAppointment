import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class FacultyCubit extends Cubit<FacultyState> {
  FacultyCubit() : super(FacultyInitial());

  void loadDashboard() async {
    emit(FacultyLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(FacultyLoaded(
      totalRequests: 8,
      pending: 5,
      accepted: 2,
      rejected: 1,
      pendingRequests: [
        PendingRequestData(
          studentName: 'Maria Garcia',
          studentInitials: 'MG',
          date: 'May 18, 2026',
          time: '2:00 PM',
        ),
        PendingRequestData(
          studentName: 'Juan Dela Cruz',
          studentInitials: 'JD',
          date: 'May 19, 2026',
          time: '9:00 AM',
        ),
        PendingRequestData(
          studentName: 'Ana Reyes',
          studentInitials: 'AR',
          date: 'May 20, 2026',
          time: '11:00 AM',
        ),
      ],
    ));
  }
}

sealed class FacultyState {}

class FacultyInitial extends FacultyState {}

class FacultyLoading extends FacultyState {}

class FacultyLoaded extends FacultyState {
  final int totalRequests;
  final int pending;
  final int accepted;
  final int rejected;
  final List<PendingRequestData> pendingRequests;

  FacultyLoaded({
    required this.totalRequests,
    required this.pending,
    required this.accepted,
    required this.rejected,
    required this.pendingRequests,
  });
}

class FacultyError extends FacultyState {
  final String message;
  FacultyError(this.message);
}

class PendingRequestData {
  final String studentName;
  final String studentInitials;
  final String date;
  final String time;

  PendingRequestData({
    required this.studentName,
    required this.studentInitials,
    required this.date,
    required this.time,
  });
}
