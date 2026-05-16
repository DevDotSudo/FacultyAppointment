import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFEEEFF2)),
            boxShadow: isDark ? null : [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 1)),
            ],
          ),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(initials,
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.textDark)),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.access_time_rounded, size: 11,
                    color: isDark ? AppColors.darkMuted : AppColors.textMuted),
                  const SizedBox(width: 3),
                  Text(dateTime, style: GoogleFonts.inter(fontSize: 11,
                    color: isDark ? AppColors.darkMuted : AppColors.textMuted)),
                ]),
                if (purpose.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(purpose, style: GoogleFonts.inter(fontSize: 11,
                    color: isDark ? AppColors.darkMuted : AppColors.textSecondary),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ]),
            ),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              AppointmentStatusBadge(status: status),
              if (actionButton != null) ...[const SizedBox(height: 4), actionButton!],
            ]),
          ]),
        ),
      ),
    );
  }
}
