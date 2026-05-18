import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class StatCardWidget extends StatelessWidget {
  final String label;
  final String number;
  final Color accentColor;
  final IconData icon;
  final VoidCallback? onViewAll;

  const StatCardWidget({
    super.key,
    required this.label,
    required this.number,
    required this.accentColor,
    required this.icon,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    return Container(
      padding: Responsive.cardPadding(screenWidth),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(Responsive.cardRadius(screenWidth)),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 22, color: accentColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                  style: GoogleFonts.inter(
                    fontSize: Responsive.label(screenWidth).fontSize,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                const SizedBox(height: 2),
                Text(number,
                  style: GoogleFonts.inter(
                    fontSize: Responsive.display1(screenWidth).fontSize! - 4,
                    fontWeight: FontWeight.w700,
                    color: accentColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}