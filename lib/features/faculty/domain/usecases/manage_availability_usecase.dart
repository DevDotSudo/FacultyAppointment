import 'package:cloud_firestore/cloud_firestore.dart';

class ManageAvailabilityUseCase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addSchedule({
    required String facultyId,
    required String day,
    required String startTime,
    required String endTime,
  }) async {
    await _firestore.collection('faculty_availability').add({
      'faculty_id': facultyId,
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
      'is_active': true,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateSchedule({
    required String scheduleId,
    required String day,
    required String startTime,
    required String endTime,
  }) async {
    await _firestore.collection('faculty_availability').doc(scheduleId).update({
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSchedule({
    required String scheduleId,
  }) async {
    await _firestore.collection('faculty_availability').doc(scheduleId).delete();
  }
}