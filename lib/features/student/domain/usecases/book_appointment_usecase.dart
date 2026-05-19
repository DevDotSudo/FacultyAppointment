import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/widgets/notification_service.dart';

class BookAppointmentUseCase {
  final _firestore = FirebaseFirestore.instance;
  final _notif = NotificationService();

  Future<void> call({
    required String studentId,
    required String studentName,
    required String facultyId,
    required String facultyName,
    required String facultyInitials,
    required String date,
    required String time,
    required String purpose,
    String? scheduleId,
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
      'schedule_id': ?scheduleId,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });

    await _notif.createNotification(
      userId: facultyId,
      title: 'New Appointment Request',
      message: '$studentName has requested an appointment on $date at $time.',
      type: 'request',
    );
  }
}
