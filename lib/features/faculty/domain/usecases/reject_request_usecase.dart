import 'package:cloud_firestore/cloud_firestore.dart';

class RejectRequestUseCase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> call({
    required String requestId,
    String? reason,
  }) async {
    await _firestore.collection('appointment_requests').doc(requestId).update({
      'status': 'rejected',
      'rejection_reason': reason ?? '',
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}