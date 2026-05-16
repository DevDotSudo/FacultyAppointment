class AppointmentEntity {
  final String id;
  final String studentId;
  final String facultyId;
  final String date;
  final String time;
  final String purpose;
  final String status;
  final String facultyName;
  final String facultyInitials;
  final String studentName;

  AppointmentEntity({
    required this.id,
    required this.studentId,
    required this.facultyId,
    required this.date,
    required this.time,
    required this.purpose,
    required this.status,
    required this.facultyName,
    required this.facultyInitials,
    required this.studentName,
  });

  factory AppointmentEntity.fromMap(Map<String, dynamic> map) {
    return AppointmentEntity(
      id: map['id'] as String,
      studentId: map['student_id'] as String,
      facultyId: map['faculty_id'] as String,
      date: map['date'] as String,
      time: map['time'] as String,
      purpose: map['purpose'] as String,
      status: map['status'] as String,
      facultyName: map['faculty_name'] as String,
      facultyInitials: map['faculty_initials'] as String,
      studentName: map['student_name'] as String,
    );
  }
}
