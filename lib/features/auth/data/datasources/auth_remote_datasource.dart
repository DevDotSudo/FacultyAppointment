import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRemoteDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> signUp({required String email, required String password}) {
    try {
      return _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint('❌ FIRESTORE: signUp failed — $e');
      rethrow;
    }
  }

  Future<UserCredential> signIn({required String email, required String password}) {
    try {
      return _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint('❌ FIRESTORE: signIn failed — $e');
      rethrow;
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<String?> getUserRole(String uid) async {
    try {
      final studentDoc = await _firestore.collection('students').doc(uid).get();
      if (studentDoc.exists) {
        return 'student';
      }
      final facultyDoc = await _firestore.collection('faculty').doc(uid).get();
      if (facultyDoc.exists) {
        return 'faculty';
      }
      return null;
    } catch (e) {
      debugPrint('❌ FIRESTORE: getUserRole failed for uid=$uid — $e');
      rethrow;
    }
  }

  Future<void> insertUserProfile({
    required String id,
    required String role,
    required String fullName,
    required String email,
    required String phone,
    // Faculty-only
    String? department,
    String? specialization,
    String? officeLocation,
    // Student-only
    String? studentId,
  }) async {
    try {
      if (role == 'student') {
        await _firestore.collection('students').doc(id).set({
          'id': id,
          'email': email,
          'full_name': fullName,
          'photo_url': '',
          'phone': phone,
          'student_id': studentId ?? 'STU-${id.substring(0, 8)}',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
          'role': 'student',
        });
      } else {
        await _firestore.collection('faculty').doc(id).set({
          'id': id,
          'email': email,
          'full_name': fullName,
          'photo_url': '',
          'phone': phone,
          'department': department ?? '',
          'specialization': specialization ?? '',
          'office_location': officeLocation ?? '',
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
          'role': 'faculty',
        });
      }
    } catch (e) {
      debugPrint('❌ FIRESTORE: insertUserProfile failed for id=$id role=$role — $e');
      rethrow;
    }
  }
}