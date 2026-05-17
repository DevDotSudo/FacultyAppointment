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
    await _firestore.collection('appointment_requests').doc(requestId).update({
      'status': 'cancelled',
      'updated_at': FieldValue.serverTimestamp(),
    });

    // Notify faculty about the cancellation
    await _notificationService.createNotification(
      userId: facultyId,
      title: 'Appointment Cancelled',
      message: '$studentName has cancelled their appointment request.',
      type: 'cancel',
    );
  }
}
