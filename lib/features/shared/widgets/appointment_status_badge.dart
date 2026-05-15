import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AppointmentStatusBadge extends StatelessWidget {
  final String status;

  const AppointmentStatusBadge({super.key, required this.status});

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'accepted':
        return AppColors.success;
      case 'rejected':
        return AppColors.danger;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getStatusColor().withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
