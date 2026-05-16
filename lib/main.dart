import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/utils/firestore_debug.dart';
export 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('═══════════════════════════════════════════');
  debugPrint('🔥 FIREBASE: Initializing...');
  debugPrint('═══════════════════════════════════════════');

  try {
    final app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint('✅ FIREBASE: Initialized successfully');
    debugPrint('   📦 Project ID  : ${app.options.projectId}');
    debugPrint('   🔑 API Key     : ${app.options.apiKey}');
    debugPrint('   📱 App ID      : ${app.options.appId}');
    debugPrint('   📨 Sender ID   : ${app.options.messagingSenderId}');
    debugPrint('   🗄️  Storage     : ${app.options.storageBucket}');
    debugPrint('   🌐 Auth Domain : ${app.options.authDomain}');
    debugPrint('   📊 Measurement : ${app.options.measurementId}');
    debugPrint('   🏷️  Name        : ${app.name}');
    debugPrint('═══════════════════════════════════════════');

    FirestoreDebug.enable();
  } catch (e, st) {
    debugPrint('❌ FIREBASE: Initialization FAILED');
    debugPrint('   Error: $e');
    debugPrint('   Stack: $st');
    debugPrint('═══════════════════════════════════════════');
    rethrow;
  }

  await init();
  runApp(const MyApp());
}
