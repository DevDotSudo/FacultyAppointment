import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreDebug {
  static bool _initialized = false;

  static Future<void> enable() async {
    if (_initialized) return;
    _initialized = true;

    debugPrint('═══════════════════════════════════════════');
    debugPrint('🔍 FIRESTORE DEBUG: Enabling...');
    debugPrint('═══════════════════════════════════════════');

    try {
      FirebaseFirestore.setLoggingEnabled(true);
      debugPrint('✅ FIRESTORE: Native SDK logging enabled');
    } catch (e) {
      debugPrint('⚠️  FIRESTORE: setLoggingEnabled not available: $e');
    }

    FlutterError.onError = (FlutterErrorDetails details) {
      final error = details.exception;
      if (_isFirestoreError(error)) {
        debugPrint('═══════════════════════════════════════════');
        debugPrint('🔥 FIRESTORE FLUTTER ERROR:');
        debugPrint('   Summary: ${details.summary}');
        debugPrint('   Error: $error');
        if (details.stack != null) {
          final stackLines = details.stack.toString().split('\n');
          for (final line in stackLines.take(15)) {
            debugPrint('   $line');
          }
        }
        debugPrint('═══════════════════════════════════════════');
      }
      FlutterError.dumpErrorToConsole(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      if (_isFirestoreError(error)) {
        debugPrint('═══════════════════════════════════════════');
        debugPrint('🔥 FIRESTORE PLATFORM ERROR:');
        debugPrint('   Error: $error');
        final stackLines = stack.toString().split('\n');
        for (final line in stackLines.take(15)) {
          debugPrint('   $line');
        }
        debugPrint('═══════════════════════════════════════════');
      }
      return false;
    };

    debugPrint('✅ FIRESTORE: Error interceptors installed');
    debugPrint('═══════════════════════════════════════════');
  }

  static bool _isFirestoreError(Object error) {
    final type = error.runtimeType.toString();
    final message = error.toString().toLowerCase();
    return type.contains('Firebase') ||
        type.contains('Firestore') ||
        type.contains('firebase') ||
        message.contains('firestore') ||
        message.contains('firebase') ||
        message.contains('cloud_firestore') ||
        message.contains('permission-denied') ||
        message.contains('unavailable') ||
        message.contains('not-found') ||
        message.contains('already-exists') ||
        message.contains('invalid-argument') ||
        message.contains('deadline-exceeded') ||
        message.contains('resource-exhausted') ||
        message.contains('unauthenticated') ||
        message.contains('permission_denied') ||
        message.contains('failed-precondition');
  }
}
