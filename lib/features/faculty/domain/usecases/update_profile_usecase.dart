import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateProfileUseCase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> call({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    data['updated_at'] = FieldValue.serverTimestamp();
    await _firestore.collection('faculty').doc(userId).update(data);
  }
}