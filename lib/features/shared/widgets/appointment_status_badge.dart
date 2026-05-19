import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class AppointmentStatusBadge extends StatelessWidget {
  final String status;
  const AppointmentStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    if (status.isEmpty) return const SizedBox.shrink();
    final cfg = _cfg(status.toLowerCase());
    final label = status[0].toUpperCase() + status.substring(1).toLowerCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: cfg.bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: cfg.fg)),
    );
  }

  _Cfg _cfg(String s) {
    switch (s) {
      case 'pending':
        return _Cfg(AppColors.statusPendingBg, AppColors.statusPendingText);
      case 'accepted':
      case 'approved':
        return _Cfg(AppColors.statusAcceptedBg, AppColors.statusAcceptedText);
      case 'rejected':
        return _Cfg(AppColors.statusRejectedBg, AppColors.statusRejectedText);
      case 'completed':
        return _Cfg(const Color(0xFFEDE9FE), const Color(0xFF5B21B6));
      case 'rescheduled':
        return _Cfg(const Color(0xFFDBEAFE), const Color(0xFF1D4ED8));
      case 'cancelled':
        return _Cfg(AppColors.statusCancelledBg, AppColors.statusCancelledText);
      default:
        return _Cfg(AppColors.statusCancelledBg, AppColors.statusCancelledText);
    }
  }
}

class _Cfg {
  final Color bg, fg;
  const _Cfg(this.bg, this.fg);
}
