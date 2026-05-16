import 'package:faculty_appointment/features/student/domain/entities/faculty_entity.dart';
import 'package:faculty_appointment/features/student/domain/repositories/student_repository.dart';

class GetFacultyListUseCase {
  final StudentRepository _repository;

  GetFacultyListUseCase(this._repository);

  Future<List<FacultyEntity>> call() async {
    return await _repository.getFacultyList();
  }
}
