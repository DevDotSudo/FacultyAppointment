class FacultyEntity {
  final String id;
  final String fullName;
  final String department;
  final String specialization;
  final String officeLocation;
  final String email;
  final String phone;

  FacultyEntity({
    required this.id,
    required this.fullName,
    required this.department,
    required this.specialization,
    required this.officeLocation,
    required this.email,
    required this.phone,
  });

  factory FacultyEntity.fromMap(Map<String, dynamic> map) {
    return FacultyEntity(
      id: map['id'] as String,
      fullName: map['full_name'] as String,
      department: map['department'] as String,
      specialization: map['specialization'] as String,
      officeLocation: map['office_location'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
    );
  }
}
