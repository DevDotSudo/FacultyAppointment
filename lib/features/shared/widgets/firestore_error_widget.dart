import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Converts a Firestore exception to a user-friendly message.
String firestoreErrorMessage(Object? error) {
  final msg = error?.toString() ?? '';
  if (msg.contains('FAILED_PRECONDITION') || msg.contains('requires an index')) {
    return 'A database index is required. Please contact the administrator.';
  }
  if (msg.contains('PERMISSION_DENIED')) return 'Permission denied.';
  if (msg.contains('NOT_FOUND')) return 'Data not found.';
  if (msg.contains('unavailable') || msg.contains('network')) {
    return 'No internet connection. Please check your network.';
  }
  return 'Failed to load data. Please try again.';
}

/// Drop-in error widget for StreamBuilder / FutureBuilder.
class FirestoreErrorWidget extends StatelessWidget {
  final Object? error;
  const FirestoreErrorWidget(this.error, {super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.cloud_off_rounded, size: 40, color: mutedColor),
          const SizedBox(height: 8),
          Text(firestoreErrorMessage(error),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: mutedColor)),
        ]),
      ),
    );
  }
}
