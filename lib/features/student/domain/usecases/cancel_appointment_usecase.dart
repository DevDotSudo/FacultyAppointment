import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/widgets/notification_service.dart';

class CancelAppointmentUseCase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  Future<void> call({
    required String requestId,
    required String facultyId,
    required String studentName,
  }) async {
    final doc = await _firestore.collection('appointment_requests').doc(requestId).get();
    final scheduleId = doc.data()?['schedule_id'] as String?;

    await _firestore.collection('appointment_requests').doc(requestId).update({
      'status': 'cancelled',
      'updated_at': FieldValue.serverTimestamp(),
    });

    if (scheduleId != null) {
      await _firestore.collection('faculty_availability').doc(scheduleId).update({
        'booked_slots': FieldValue.increment(-1),
      });
    }

    await _notificationService.createNotification(
      userId: facultyId,
      title: 'Appointment Cancelled',
      message: '$studentName has cancelled their appointment request.',
      type: 'cancel',
    );
  }
}
