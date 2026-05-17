import 'package:faculty_appointment/features/faculty/domain/entities/appointment_request_entity.dart';
import 'package:faculty_appointment/features/faculty/domain/entities/availability_entity.dart';

abstract class FacultyRepository {
  Future<List<AppointmentRequestEntity>> getAppointmentRequests(String facultyId);
  Future<List<AppointmentRequestEntity>> getPendingRequests(String facultyId);
  Future<List<AvailabilityEntity>> getFacultySchedule(String facultyId);
  Future<void> updateProfile(String userId, Map<String, dynamic> data);
  Future<void> acceptRequest(String requestId, {String? notes});
  Future<void> rejectRequest(String requestId, {String? reason});
  Future<void> addAvailability(Map<String, dynamic> data);
  Future<void> updateAvailability(String scheduleId, Map<String, dynamic> data);
  Future<void> deleteAvailability(String scheduleId);
}
