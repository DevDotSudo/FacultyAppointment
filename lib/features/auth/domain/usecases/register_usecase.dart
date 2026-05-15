import 'package:faculty_appointment/features/auth/data/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<void> call({
    required String email,
    required String password,
    required String role,
    required String fullName,
    required String phone,
    // Faculty-only
    String? department,
    String? specialization,
    String? officeLocation,
    // Student-only
    String? studentId,
  }) {
    return _repository.register(
      email: email,
      password: password,
      role: role,
      fullName: fullName,
      phone: phone,
      department: department,
      specialization: specialization,
      officeLocation: officeLocation,
      studentId: studentId,
    );
  }
}