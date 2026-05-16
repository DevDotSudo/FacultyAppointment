import 'package:cloud_firestore/cloud_firestore.dart';

class AcceptRequestUseCase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> call({
    required String requestId,
    String? notes,
  }) async {
    await _firestore.collection('appointment_requests').doc(requestId).update({
      'status': 'accepted',
      'notes': notes ?? '',
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}