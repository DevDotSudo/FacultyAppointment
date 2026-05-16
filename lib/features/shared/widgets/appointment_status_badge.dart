import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class AppointmentStatusBadge extends StatelessWidget {
  final String status;

  const AppointmentStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        config.label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: config.textColor,
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return _StatusConfig(
          label: 'Pending',
          bgColor: AppColors.statusPendingBg,
          textColor: AppColors.statusPendingText,
        );
      case 'accepted':
        return _StatusConfig(
          label: 'Accepted',
          bgColor: AppColors.statusAcceptedBg,
          textColor: AppColors.statusAcceptedText,
        );
      case 'rejected':
        return _StatusConfig(
          label: 'Rejected',
          bgColor: AppColors.statusRejectedBg,
          textColor: AppColors.statusRejectedText,
        );
      case 'cancelled':
        return _StatusConfig(
          label: 'Cancelled',
          bgColor: AppColors.statusCancelledBg,
          textColor: AppColors.statusCancelledText,
        );
      default:
        return _StatusConfig(
          label: status,
          bgColor: AppColors.statusCancelledBg,
          textColor: AppColors.statusCancelledText,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color bgColor;
  final Color textColor;

  _StatusConfig({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });
}