abstract class AuthRepository {
  Future<void> login({
    required String email,
    required String password,
  });

  Future<void> register({
    required String email,
    required String password,
    required String role,
    required String fullName,
    required String phone,
    String? department,
    String? specialization,
    String? officeLocation,
    String? studentId,
  });

  Future<void> logout();
}