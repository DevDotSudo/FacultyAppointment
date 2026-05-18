import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import 'appointment_status_badge.dart';

class AppointmentTile extends StatelessWidget {
  final String name;
  final String dateTime;
  final String purpose;
  final String status;
  final Widget? actionButton;
  final VoidCallback? onTap;

  const AppointmentTile({
    super.key,
    required this.name,
    required this.dateTime,
    required this.purpose,
    required this.status,
    this.actionButton,
    this.onTap,
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Responsive.cardRadius(screenWidth)),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Text(
                name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase(),
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary))),
            ),
            SizedBox(width: Responsive.s12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                    style: GoogleFonts.inter(
                      fontSize: Responsive.body(screenWidth).fontSize,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
                  const SizedBox(height: 2),
                  Text(dateTime,
                    style: GoogleFonts.inter(
                      fontSize: Responsive.small(screenWidth).fontSize,
                      color: mutedColor)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AppointmentStatusBadge(status: status),
            if (actionButton != null) ...[
              const SizedBox(width: 8),
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }
}