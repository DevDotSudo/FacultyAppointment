import 'package:faculty_appointment/features/faculty/domain/entities/appointment_request_entity.dart';
import 'package:faculty_appointment/features/faculty/domain/repositories/faculty_repository.dart';

class GetAppointmentRequestsUseCase {
  final FacultyRepository _repository;

  GetAppointmentRequestsUseCase(this._repository);

  Future<List<AppointmentRequestEntity>> call(String facultyId) async {
    return await _repository.getAppointmentRequests(facultyId);
  }
}
