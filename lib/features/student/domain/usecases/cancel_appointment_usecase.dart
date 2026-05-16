import 'package:cloud_firestore/cloud_firestore.dart';

class CancelAppointmentUseCase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> call({
    required String requestId,
  }) async {
    await _firestore.collection('appointment_requests').doc(requestId).update({
      'status': 'cancelled',
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}