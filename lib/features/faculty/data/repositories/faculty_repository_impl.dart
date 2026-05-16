import 'package:faculty_appointment/features/faculty/data/datasources/faculty_remote_datasource.dart';
import 'package:faculty_appointment/features/faculty/domain/entities/appointment_request_entity.dart';
import 'package:faculty_appointment/features/faculty/domain/entities/availability_entity.dart';
import 'package:faculty_appointment/features/faculty/domain/repositories/faculty_repository.dart';

class FacultyRepositoryImpl implements FacultyRepository {
  final FacultyRemoteDatasource _remoteDatasource;

  FacultyRepositoryImpl(this._remoteDatasource);

  @override
  Future<List<AppointmentRequestEntity>> getAppointmentRequests(String facultyId) async {
    final data = await _remoteDatasource.getAppointmentRequests(facultyId);
    return data.map((d) => AppointmentRequestEntity.fromMap(d)).toList();
  }

  @override
  Future<List<AppointmentRequestEntity>> getPendingRequests(String facultyId) async {
    final data = await _remoteDatasource.getPendingRequests(facultyId);
    return data.map((d) => AppointmentRequestEntity.fromMap(d)).toList();
  }

  @override
  Future<List<AvailabilityEntity>> getFacultySchedule(String facultyId) async {
    final data = await _remoteDatasource.getFacultySchedule(facultyId);
    return data.map((d) => AvailabilityEntity.fromMap(d)).toList();
  }
}
