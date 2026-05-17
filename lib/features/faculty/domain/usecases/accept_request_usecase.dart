import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/widgets/notification_service.dart';

class AcceptRequestUseCase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  Future<void> call({
    required String requestId,
    required String studentId,
    String? notes,
  }) async {
    // Fetch the request data to get student info before updating
    final requestDoc = await _firestore.collection('appointment_requests').doc(requestId).get();
    final requestData = requestDoc.data();

    await _firestore.collection('appointment_requests').doc(requestId).update({
      'status': 'accepted',
      'notes': notes ?? '',
      'updated_at': FieldValue.serverTimestamp(),
    });

    if (requestData != null) {
      // Notify student that the request was accepted
      await _notificationService.createNotification(
        userId: studentId,
        title: 'Appointment Accepted',
        message: 'Your appointment request has been accepted by the faculty.',
        type: 'accept',
      );
    }
  }
}
