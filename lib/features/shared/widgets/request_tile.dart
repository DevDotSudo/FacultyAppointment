import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class RequestTile extends StatelessWidget {
  final String studentName;
  final String dateTime;
  final String purpose;
  final VoidCallback? onView;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const RequestTile({
    super.key,
    required this.studentName,
    required this.dateTime,
    required this.purpose,
    this.onView,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initials = studentName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(initials,
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.warning)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(studentName, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600,
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
          if (onAccept != null && onReject != null)
            Row(mainAxisSize: MainAxisSize.min, children: [
              _ActionBtn(label: '✓', color: AppColors.success, onTap: onAccept!),
              const SizedBox(width: 6),
              _ActionBtn(label: '✕', color: AppColors.danger, onTap: onReject!),
            ])
          else if (onView != null)
            _ViewBtn(onTap: onView!),
        ]),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Center(child: Text(label, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold))),
      ),
    );
  }
}

class _ViewBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _ViewBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Text('View', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
