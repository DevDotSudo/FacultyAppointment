import 'package:cloud_firestore/cloud_firestore.dart';

class ManageAvailabilityUseCase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addSchedule({
    required String facultyId,
    required String day,
    required String startTime,
    required String endTime,
    DateTime? date,
    String consultationType = 'face-to-face',
    String locationOrLink = '',
    int maxSlots = 1,
  }) async {
    await _firestore.collection('faculty_availability').add({
      'faculty_id': facultyId,
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
      'is_active': true,
      'date': date != null ? Timestamp.fromDate(date) : null,
      'consultation_type': consultationType,
      'location_or_link': locationOrLink,
      'max_slots': maxSlots,
      'booked_slots': 0,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateSchedule({
    required String scheduleId,
    required String day,
    required String startTime,
    required String endTime,
    DateTime? date,
    String consultationType = 'face-to-face',
    String locationOrLink = '',
    int maxSlots = 1,
  }) async {
    await _firestore.collection('faculty_availability').doc(scheduleId).update({
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
      'date': date != null ? Timestamp.fromDate(date) : null,
      'consultation_type': consultationType,
      'location_or_link': locationOrLink,
      'max_slots': maxSlots,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSchedule({required String scheduleId}) async {
    await _firestore.collection('faculty_availability').doc(scheduleId).delete();
  }

  /// Atomically increment booked_slots (called when student books)
  Future<void> incrementBookedSlots(String scheduleId) async {
    await _firestore.collection('faculty_availability').doc(scheduleId).update({
      'booked_slots': FieldValue.increment(1),
    });
  }

  /// Atomically decrement booked_slots (called when appointment is cancelled/rejected)
  Future<void> decrementBookedSlots(String scheduleId) async {
    await _firestore.collection('faculty_availability').doc(scheduleId).update({
      'booked_slots': FieldValue.increment(-1),
    });
  }
}
