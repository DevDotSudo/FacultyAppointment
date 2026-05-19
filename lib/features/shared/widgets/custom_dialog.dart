import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

/// Responsive dialog that automatically adapts to screen size:
/// - Mobile (< 768px): Shows as bottom sheet
/// - Desktop (>= 768px): Shows as centered dialog
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

  /// Show a responsive dialog that adapts to screen size
  /// RECOMMENDED: Use this method for better mobile support
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    List<Widget>? actions,
    bool stackedActions = false,
    bool barrierDismissible = true,
  }) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = Responsive.isMobile(width);

    if (isMobile) {
      // Mobile: Show as bottom sheet
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: barrierDismissible,
        enableDrag: barrierDismissible,
        builder: (ctx) => _MobileDialogSheet(
          title: title,
          actions: actions,
          stackedActions: stackedActions,
          child: child,
        ),
      );
    }

    // Desktop: Show as dialog
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) => Dialog(
        child: _DesktopDialogContent(
          title: title,
          actions: actions,
          stackedActions: stackedActions,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = Responsive.isMobile(width);

    if (isMobile) {
      // For mobile, use a properly constrained dialog aligned to bottom
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: width,
          ),
          child: _MobileDialogSheet(
            title: title,
            actions: actions,
            stackedActions: stackedActions,
            child: child,
          ),
        ),
      );
    }

    // For desktop, wrap in Dialog
    return Dialog(
      child: _DesktopDialogContent(
        title: title,
        actions: actions,
        stackedActions: stackedActions,
        child: child,
      ),
    );
  }
}

// Mobile bottom sheet implementation
class _MobileDialogSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool stackedActions;

  const _MobileDialogSheet({
    required this.title,
    required this.child,
    this.actions,
    this.stackedActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final cardBg = isDark ? AppColors.darkCardBg : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor)),
                    const SizedBox(height: 16),
                    child,
                    if (actions != null) ...[
                      const SizedBox(height: 20),
                      if (stackedActions)
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: actions!)
                      else
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: actions!),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Desktop dialog implementation
class _DesktopDialogContent extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool stackedActions;

  const _DesktopDialogContent({
    required this.title,
    required this.child,
    this.actions,
    this.stackedActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final cardBg = isDark ? AppColors.darkCardBg : Colors.white;

    return Container(
      constraints: const BoxConstraints(
        maxWidth: 420,
        maxHeight: 600,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Text(title,
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded,
                      size: 20,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Divider(
              height: 1,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  child,
                  if (actions != null) ...[
                    const SizedBox(height: 20),
                    if (stackedActions)
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: actions!)
                    else
                      Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: actions!),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}