import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> getStudentProfile() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('Not authenticated');
      final doc = await _firestore.collection('students').doc(uid).get();
      if (!doc.exists) throw Exception('Student profile not found');
      return doc.data()!;
    } catch (e) {
      debugPrint('❌ FIRESTORE: getStudentProfile failed — $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getMyAppointments(String studentId) async {
    try {
      final snapshot = await _firestore
          .collection('appointment_requests')
          .where('student_id', isEqualTo: studentId)
          .orderBy('created_at', descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      debugPrint('❌ FIRESTORE: getMyAppointments failed for studentId=$studentId — $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUpcomingAppointments(String studentId) async {
    try {
      final snapshot = await _firestore
          .collection('appointment_requests')
          .where('student_id', isEqualTo: studentId)
          .where('status', isEqualTo: 'pending')
          .orderBy('created_at')
          .limit(5)
          .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      debugPrint('❌ FIRESTORE: getUpcomingAppointments failed for studentId=$studentId — $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getFacultyList() async {
    try {
      final snapshot = await _firestore
          .collection('faculty')
          .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      debugPrint('❌ FIRESTORE: getFacultyList failed — $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getFacultyById(String facultyId) async {
    try {
      final doc = await _firestore.collection('faculty').doc(facultyId).get();
      if (doc.exists) return {'id': doc.id, ...doc.data()!};
      return null;
    } catch (e) {
      debugPrint('❌ FIRESTORE: getFacultyById failed for facultyId=$facultyId — $e');
      rethrow;
    }
  }

  Future<void> bookAppointment(Map<String, dynamic> data) async {
    try {
      data['created_at'] = FieldValue.serverTimestamp();
      data['updated_at'] = FieldValue.serverTimestamp();
      await _firestore.collection('appointment_requests').add(data);
    } catch (e) {
      debugPrint('❌ FIRESTORE: bookAppointment failed — $e');
      rethrow;
    }
  }

  Future<void> cancelAppointment(String requestId) async {
    try {
      await _firestore.collection('appointment_requests').doc(requestId).update({
        'status': 'cancelled',
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('❌ FIRESTORE: cancelAppointment failed for requestId=$requestId — $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getStudentProfileById(String studentId) async {
    try {
      final doc = await _firestore.collection('students').doc(studentId).get();
      if (!doc.exists) throw Exception('Student profile not found');
      return doc.data()!;
    } catch (e) {
      debugPrint('❌ FIRESTORE: getStudentProfileById failed for studentId=$studentId — $e');
      rethrow;
    }
  }
}
