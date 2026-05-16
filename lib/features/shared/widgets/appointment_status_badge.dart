import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AppointmentStatusBadge extends StatelessWidget {
  final String status;

  const AppointmentStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final config = _statusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1).toLowerCase(),
        style: textTheme.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: config.textColor,
        ),
      ),
    );
  }

  _StatusConfig _statusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return _StatusConfig(
          AppColors.statusPendingBg,
          AppColors.statusPendingText,
        );
      case 'accepted':
        return _StatusConfig(
          AppColors.statusAcceptedBg,
          AppColors.statusAcceptedText,
        );
      case 'rejected':
        return _StatusConfig(
          AppColors.statusRejectedBg,
          AppColors.statusRejectedText,
        );
      default:
        return _StatusConfig(
          AppColors.statusCancelledBg,
          AppColors.statusCancelledText,
        );
    }
  }
}

class _StatusConfig {
  final Color bgColor;
  final Color textColor;
  _StatusConfig(this.bgColor, this.textColor);
}
