import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentRequestEntity {
  final String id;
  final String studentId;
  final String facultyId;
  final String date;
  final String time;
  final String purpose;
  final String status;
  final String studentName;
  final String studentInitials;
  final DateTime createdAt;

  AppointmentRequestEntity({
    required this.id,
    required this.studentId,
    required this.facultyId,
    required this.date,
    required this.time,
    required this.purpose,
    required this.status,
    required this.studentName,
    required this.studentInitials,
    required this.createdAt,
  });

  factory AppointmentRequestEntity.fromMap(Map<String, dynamic> map) {
    return AppointmentRequestEntity(
      id: map['id'] as String,
      studentId: map['student_id'] as String,
      facultyId: map['faculty_id'] as String,
      date: map['date'] as String,
      time: map['time'] as String,
      purpose: map['purpose'] as String,
      status: map['status'] as String,
      studentName: map['student_name'] as String,
      studentInitials: map['student_initials'] as String,
      createdAt: (map['created_at'] as Timestamp).toDate(),
    );
  }
}
