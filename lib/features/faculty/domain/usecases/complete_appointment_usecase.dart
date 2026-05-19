import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/widgets/notification_service.dart';

class CompleteAppointmentUseCase {
  final _firestore = FirebaseFirestore.instance;
  final _notif = NotificationService();

  Future<void> call({required String requestId, required String studentId}) async {
    await _firestore.collection('appointment_requests').doc(requestId).update({
      'status': 'completed',
      'completed_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
    await _notif.createNotification(
      userId: studentId,
      title: 'Appointment Completed',
      message: 'Your appointment has been marked as completed.',
      type: 'complete',
    );
  }
}
