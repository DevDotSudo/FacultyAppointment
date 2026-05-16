import 'package:faculty_appointment/features/student/domain/entities/appointment_entity.dart';
import 'package:faculty_appointment/features/student/domain/entities/faculty_entity.dart';

abstract class StudentRepository {
  Future<List<AppointmentEntity>> getMyAppointments(String studentId);
  Future<List<AppointmentEntity>> getUpcomingAppointments(String studentId);
  Future<List<FacultyEntity>> getFacultyList();
  Future<FacultyEntity?> getFacultyById(String facultyId);
}
