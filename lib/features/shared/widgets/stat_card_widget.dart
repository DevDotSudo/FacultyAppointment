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
    final w = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCardBg : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
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
              Container(
                padding: EdgeInsets.all(Responsive.s8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(Responsive.cardRadius(w) * 0.7),
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
              const Spacer(),
              if (onViewAll != null)
                InkWell(
                  onTap: onViewAll,
                  borderRadius: BorderRadius.circular(6),
                  child: Icon(Icons.arrow_forward_ios_rounded,
                    size: 10, color: mutedColor),
                ),
            ],
          ),
          SizedBox(height: Responsive.s12),
          Text(label,
            style: GoogleFonts.inter(
              fontSize: Responsive.small(w).fontSize,
              color: mutedColor,
              fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(number,
            style: GoogleFonts.inter(
              fontSize: Responsive.display1(w).fontSize,
              fontWeight: FontWeight.w800,
              color: textColor,
              height: 1.1)),
        ],
      ),
    );
  }
}