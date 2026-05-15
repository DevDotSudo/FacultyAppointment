enum UserRole { student, faculty }

class UserEntity {
  final String id;
  final String email;
  final UserRole role;

  const UserEntity({required this.id, required this.email, required this.role});
}

class StudentEntity extends UserEntity {
  final String fullName;
  final String? photoUrl;
  final String phone;
  final String studentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StudentEntity({
    required super.id,
    required super.email,
    required this.fullName,
    this.photoUrl,
    required this.phone,
    required this.studentId,
    required this.createdAt,
    required this.updatedAt,
  }) : super(role: UserRole.student);
}

class FacultyEntity extends UserEntity {
  final String fullName;
  final String? photoUrl;
  final String phone;
  final String department;
  final String specialization;
  final String officeLocation;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FacultyEntity({
    required super.id,
    required super.email,
    required this.fullName,
    this.photoUrl,
    required this.phone,
    required this.department,
    required this.specialization,
    required this.officeLocation,
    required this.createdAt,
    required this.updatedAt,
  }) : super(role: UserRole.faculty);
}
