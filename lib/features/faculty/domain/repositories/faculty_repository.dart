import 'package:faculty_appointment/features/faculty/domain/entities/appointment_request_entity.dart';
import 'package:faculty_appointment/features/faculty/domain/entities/availability_entity.dart';

abstract class FacultyRepository {
  Future<List<AppointmentRequestEntity>> getAppointmentRequests(String facultyId);
  Future<List<AppointmentRequestEntity>> getPendingRequests(String facultyId);
  Future<List<AvailabilityEntity>> getFacultySchedule(String facultyId);
}
