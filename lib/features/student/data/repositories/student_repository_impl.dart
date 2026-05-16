import 'package:faculty_appointment/features/student/data/datasources/student_remote_datasource.dart';
import 'package:faculty_appointment/features/student/domain/entities/appointment_entity.dart';
import 'package:faculty_appointment/features/student/domain/entities/faculty_entity.dart';
import 'package:faculty_appointment/features/student/domain/repositories/student_repository.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentRemoteDatasource _remoteDatasource;

  StudentRepositoryImpl(this._remoteDatasource);

  @override
  Future<List<AppointmentEntity>> getMyAppointments(String studentId) async {
    final data = await _remoteDatasource.getMyAppointments(studentId);
    return data.map((d) => AppointmentEntity.fromMap(d)).toList();
  }

  @override
  Future<List<AppointmentEntity>> getUpcomingAppointments(String studentId) async {
    final data = await _remoteDatasource.getUpcomingAppointments(studentId);
    return data.map((d) => AppointmentEntity.fromMap(d)).toList();
  }

  @override
  Future<List<FacultyEntity>> getFacultyList() async {
    final data = await _remoteDatasource.getFacultyList();
    return data.map((d) => FacultyEntity.fromMap(d)).toList();
  }

  @override
  Future<FacultyEntity?> getFacultyById(String facultyId) async {
    final data = await _remoteDatasource.getFacultyById(facultyId);
    if (data != null) return FacultyEntity.fromMap(data);
    return null;
  }
}
