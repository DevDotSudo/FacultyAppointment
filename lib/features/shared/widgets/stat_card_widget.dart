import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class StatCardWidget extends StatelessWidget {
  final String label;
  final String number;
  final VoidCallback? onViewAll;
  final Color? accentColor;
  final IconData? icon;

  const StatCardWidget({
    super.key,
    required this.label,
    required this.number,
    this.onViewAll,
    this.accentColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = accentColor ?? AppColors.primary;
    final bg = isDark ? AppColors.darkCard : Colors.white;
    final border = isDark ? AppColors.darkBorder : const Color(0xFFEEEFF2);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
        boxShadow: isDark ? null : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon ?? Icons.bar_chart_rounded, size: 16, color: accent),
            ),
            const Spacer(),
            if (onViewAll != null)
              GestureDetector(
                onTap: onViewAll,
                child: Text('View →', style: GoogleFonts.inter(fontSize: 11, color: accent, fontWeight: FontWeight.w600)),
              ),
          ]),
          const SizedBox(height: 12),
          Text(number, style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.textDark)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkMuted : AppColors.textMuted)),
        ],
      ),
    );
  }
}
