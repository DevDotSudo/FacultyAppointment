import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData? titleIcon;
  final Widget child;
  final Widget? trailing;

  const DashboardCard({
    super.key,
    required this.title,
    this.titleIcon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCardBg : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      width: double.infinity,
      padding: Responsive.cardPadding(w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(Responsive.cardRadius(w)),
        border: Border.all(color: borderColor.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.transparent : Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (titleIcon != null) ...[
                Icon(titleIcon, size: 16,
                  color: mutedColor),
                const SizedBox(width: 8),
              ],
              Text(title,
                style: GoogleFonts.inter(
                  fontSize: Responsive.h4(w).fontSize,
                  fontWeight: FontWeight.w600,
                  color: textColor)),
              const Spacer(),
              ?trailing,
            ],
          ),
          SizedBox(height: Responsive.s16),
          child,
        ],
      ),
    );
  }
}