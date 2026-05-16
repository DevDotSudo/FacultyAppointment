import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../cubit/faculty_state.dart';
import '../../../../features/faculty/domain/usecases/get_pending_requests_usecase.dart';
import '../../../../features/faculty/domain/usecases/get_appointment_requests_usecase.dart';
import '../../../../features/faculty/domain/entities/pending_request_data.dart';

class FacultyCubit extends Cubit<FacultyState> {
  final GetPendingRequestsUseCase _getPendingRequests;
  final GetAppointmentRequestsUseCase _getAppointmentRequests;

  FacultyCubit(this._getPendingRequests, this._getAppointmentRequests) : super(FacultyInitial());

  void loadDashboard() async {
    emit(FacultyLoading());
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        emit(FacultyError('Not authenticated'));
        return;
      }

      final pendingRequests = await _getPendingRequests(userId);
      final allRequests = await _getAppointmentRequests(userId);

      int totalRequests = allRequests.length;
      int accepted = 0;
      int rejected = 0;

      for (var req in allRequests) {
        if (req.status == 'accepted') {
          accepted++;
        } else if (req.status == 'rejected') {
          rejected++;
        }
      }

      emit(FacultyLoaded(
        totalRequests: totalRequests,
        pending: pendingRequests.length,
        accepted: accepted,
        rejected: rejected,
      pendingRequests: pendingRequests
          .map((r) => PendingRequestData(
                studentName: r.studentName,
                studentInitials: r.studentInitials,
                date: r.date,
                time: r.time,
              ))
          .toList(),
      ));
    } catch (e) {
      emit(FacultyError(e.toString()));
    }
  }
}
