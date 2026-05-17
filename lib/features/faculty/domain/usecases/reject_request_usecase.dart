import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/widgets/notification_service.dart';

class RejectRequestUseCase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  Future<void> call({
    required String requestId,
    required String studentId,
    String? reason,
  }) async {
    await _firestore.collection('appointment_requests').doc(requestId).update({
      'status': 'rejected',
      'rejection_reason': reason ?? '',
      'updated_at': FieldValue.serverTimestamp(),
    });

    // Notify student that the request was rejected
    await _notificationService.createNotification(
      userId: studentId,
      title: 'Appointment Rejected',
      message: reason != null && reason.isNotEmpty
          ? 'Your appointment request has been rejected. Reason: $reason'
          : 'Your appointment request has been rejected.',
      type: 'reject',
    );
  }
}
