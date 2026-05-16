import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FacultyRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> getFacultyProfile() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('Not authenticated');
      final doc = await _firestore.collection('faculty').doc(uid).get();
      if (!doc.exists) throw Exception('Faculty profile not found');
      return doc.data()!;
    } catch (e) {
      debugPrint('❌ FIRESTORE: getFacultyProfile failed — $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAppointmentRequests(String facultyId) async {
    try {
      final snapshot = await _firestore
          .collection('appointment_requests')
          .where('faculty_id', isEqualTo: facultyId)
          .orderBy('created_at', descending: true)
          .limit(20)
          .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      debugPrint('❌ FIRESTORE: getAppointmentRequests failed for facultyId=$facultyId — $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPendingRequests(String facultyId) async {
    try {
      final snapshot = await _firestore
          .collection('appointment_requests')
          .where('faculty_id', isEqualTo: facultyId)
          .where('status', isEqualTo: 'pending')
          .orderBy('created_at')
          .limit(10)
          .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      debugPrint('❌ FIRESTORE: getPendingRequests failed for facultyId=$facultyId — $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getFacultySchedule(String facultyId) async {
    try {
      final snapshot = await _firestore
          .collection('faculty_availability')
          .where('faculty_id', isEqualTo: facultyId)
          .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      debugPrint('❌ FIRESTORE: getFacultySchedule failed for facultyId=$facultyId — $e');
      rethrow;
    }
  }
}