import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool stackedActions;

  const CustomDialog({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.stackedActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: AppColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            child,
            if (actions != null) ...[
              const SizedBox(height: 20),
              if (stackedActions)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: actions!,
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                ),
            ],
          ],
        ),
      ),
    );
  }
}
