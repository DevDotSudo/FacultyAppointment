import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/widgets/notification_service.dart';

class RescheduleAppointmentUseCase {
  final _firestore = FirebaseFirestore.instance;
  final _notif = NotificationService();

  Future<void> call({
    required String requestId,
    required String studentId,
    required String newDate,
    required String newTime,
    String? note,
  }) async {
    await _firestore.collection('appointment_requests').doc(requestId).update({
      'status': 'rescheduled',
      'date': newDate,
      'time': newTime,
      'proposed_date': newDate,
      'proposed_time': newTime,
      'reschedule_note': note ?? '',
      'updated_at': FieldValue.serverTimestamp(),
    });
    await _notif.createNotification(
      userId: studentId,
      title: 'Appointment Rescheduled',
      message: 'Your appointment has been rescheduled to $newDate at $newTime.',
      type: 'reschedule',
    );
  }
}
