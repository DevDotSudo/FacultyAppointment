import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class RequestTile extends StatelessWidget {
  final String studentName;
  final String dateTime;
  final String purpose;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onView;

  const RequestTile({
    super.key,
    required this.studentName,
    required this.dateTime,
    required this.purpose,
    this.onAccept,
    this.onReject,
    this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      padding: Responsive.cardPadding(screenWidth),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(Responsive.cardRadius(screenWidth)),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.statusPending.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text(
              studentName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase(),
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.statusPending))),
          ),
          SizedBox(width: Responsive.s12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(studentName,
                  style: GoogleFonts.inter(
                    fontSize: Responsive.body(screenWidth).fontSize,
                    fontWeight: FontWeight.w600,
                    color: textColor)),
                const SizedBox(height: 2),
                Text(dateTime,
                  style: GoogleFonts.inter(
                    fontSize: Responsive.small(screenWidth).fontSize,
                    color: mutedColor)),
                const SizedBox(height: 4),
                Text(purpose,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: Responsive.small(screenWidth).fontSize! - 1,
                    color: mutedColor)),
              ],
            ),
          ),
          // Actions
          if (onAccept != null && onReject != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: onAccept,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.statusAccepted.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.check_rounded, size: 18, color: AppColors.statusAccepted),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: onReject,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.statusRejected.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.close_rounded, size: 18, color: AppColors.statusRejected),
                  ),
                ),
              ],
            ),
          if (onView != null)
            IconButton(
              icon: Icon(Icons.visibility_outlined, size: 18, color: mutedColor),
              onPressed: onView,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              tooltip: 'View details',
            ),
        ],
      ),
    );
  }
}