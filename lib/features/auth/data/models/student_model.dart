import '../../domain/entities/user_entity.dart';

class StudentModel extends StudentEntity {
  const StudentModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.photoUrl,
    required super.phone,
    required super.studentId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return StudentModel(
      id: map['id'] as String,
      email: map['email'] as String,
      fullName: map['fullName'] as String? ?? map['full_name'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? map['photo_url'] as String?,
      phone: map['phone'] as String? ?? '',
      studentId: map['studentId'] as String? ?? map['student_id'] as String? ?? '',
      createdAt: parseDate(map['createdAt'] ?? map['created_at']),
      updatedAt: parseDate(map['updatedAt'] ?? map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'phone': phone,
      'studentId': studentId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'role': 'student',
    };
  }
}
