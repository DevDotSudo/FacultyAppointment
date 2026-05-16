import 'package:faculty_appointment/features/student/domain/entities/appointment_entity.dart';
import 'package:faculty_appointment/features/student/domain/repositories/student_repository.dart';

class GetUpcomingAppointmentsUseCase {
  final StudentRepository _repository;

  GetUpcomingAppointmentsUseCase(this._repository);

  Future<List<AppointmentEntity>> call(String studentId) async {
    return await _repository.getUpcomingAppointments(studentId);
  }
}
