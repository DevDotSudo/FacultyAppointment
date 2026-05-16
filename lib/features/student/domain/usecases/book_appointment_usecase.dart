import 'package:cloud_firestore/cloud_firestore.dart';

class BookAppointmentUseCase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> call({
    required String studentId,
    required String studentName,
    required String facultyId,
    required String facultyName,
    required String facultyInitials,
    required String date,
    required String time,
    required String purpose,
  }) async {
    await _firestore.collection('appointment_requests').add({
      'student_id': studentId,
      'student_name': studentName,
      'faculty_id': facultyId,
      'faculty_name': facultyName,
      'faculty_initials': facultyInitials,
      'date': date,
      'time': time,
      'purpose': purpose,
      'status': 'pending',
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}