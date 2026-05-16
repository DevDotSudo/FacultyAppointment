import 'package:faculty_appointment/features/faculty/domain/entities/pending_request_data.dart';

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