import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  final IconData? titleIcon;

  const DashboardCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.titleIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCard : Colors.white;
    final border = isDark ? AppColors.darkBorder : const Color(0xFFEEEFF2);

    return Container(
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
            child: Row(children: [
              if (titleIcon != null) ...[
                Icon(titleIcon, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.textDark)),
              ),
              ?trailing,
            ]),
          ),
          const SizedBox(height: 2),
          Divider(color: isDark ? AppColors.darkBorder : const Color(0xFFF0F1F3), height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }
}
