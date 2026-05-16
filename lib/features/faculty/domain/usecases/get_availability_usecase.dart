import 'package:faculty_appointment/features/faculty/domain/entities/availability_entity.dart';
import 'package:faculty_appointment/features/faculty/domain/repositories/faculty_repository.dart';

class GetAvailabilityUseCase {
  final FacultyRepository _repository;

  GetAvailabilityUseCase(this._repository);

  Future<List<AvailabilityEntity>> call(String facultyId) async {
    return await _repository.getFacultySchedule(facultyId);
  }
}
