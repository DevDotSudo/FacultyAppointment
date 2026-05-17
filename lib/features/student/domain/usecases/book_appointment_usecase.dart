import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/widgets/notification_service.dart';

class BookAppointmentUseCase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

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

    // Notify faculty about the new request
    await _notificationService.createNotification(
      userId: facultyId,
      title: 'New Appointment Request',
      message: '$studentName has requested an appointment on $date at $time.',
      type: 'request',
    );
  }
}
