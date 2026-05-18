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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    return Container(
      padding: Responsive.cardPadding(screenWidth),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(Responsive.cardRadius(screenWidth)),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (titleIcon != null) ...[
                Icon(titleIcon, size: 18, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                const SizedBox(width: 8),
              ],
              Text(title,
                style: GoogleFonts.inter(
                  fontSize: Responsive.h4(screenWidth).fontSize,
                  fontWeight: FontWeight.w600,
                  color: textColor)),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: Responsive.s16),
          child,
        ],
      ),
    );
  }
}