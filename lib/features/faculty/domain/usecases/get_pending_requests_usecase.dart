import 'package:faculty_appointment/features/faculty/domain/entities/appointment_request_entity.dart';
import 'package:faculty_appointment/features/faculty/domain/repositories/faculty_repository.dart';

class GetPendingRequestsUseCase {
  final FacultyRepository _repository;

  GetPendingRequestsUseCase(this._repository);

  Future<List<AppointmentRequestEntity>> call(String facultyId) async {
    return await _repository.getPendingRequests(facultyId);
  }
}
