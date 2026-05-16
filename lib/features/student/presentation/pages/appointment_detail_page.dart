import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/appointment_status_badge.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../../../shared/widgets/sidebar_nav_widget.dart';

class AppointmentDetailPage extends StatelessWidget {
  const AppointmentDetailPage({super.key});

  List<SidebarNavItem> _sidebarItems(BuildContext context) => [
        SidebarNavItem(
          label: 'Dashboard',
          icon: Icons.dashboard,
          onTap: () => context.goNamed('student-dashboard'),
        ),
        SidebarNavItem(
          label: 'Faculty',
          icon: Icons.school,
          onTap: () => context.goNamed('student-faculty'),
        ),
        SidebarNavItem(
          label: 'My Appointments',
          icon: Icons.calendar_today,
          isActive: true,
          onTap: () => context.goNamed('student-my-appointments'),
        ),
        SidebarNavItem(
          label: 'Profile',
          icon: Icons.person,
          onTap: () => context.goNamed('student-profile'),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      sidebarItems: _sidebarItems(context),
      onLogout: () => context.goNamed('login'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryBlue, size: 18),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => context.pop(),
                child: Text('Back', style: GoogleFonts.inter(fontSize: 14, color: AppColors.primaryBlue)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Detail card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              border: Border.all(color: AppColors.borderGray),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appointment Details',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 4),
                _detailRow('Faculty', 'Dr. Maria Santos'),
                const SizedBox(height: 10),
                _detailRow('Date & Time', 'Mar 27, 2025 \u00b7 10:00 AM'),
                const SizedBox(height: 10),
                _detailRow('Purpose', 'I would like to discuss my final project.'),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                    const Spacer(),
                    const AppointmentStatusBadge(status: 'pending'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Waiting for faculty response.',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Progress Stepper
          _buildProgressStepper(),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
        const Spacer(),
        SizedBox(
          width: 200,
          child: Text(value, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark), textAlign: TextAlign.right),
        ),
      ],
    );
  }

  Widget _buildProgressStepper() {
    final steps = ['Pending', 'Accepted', 'Rejected', 'Cancelled'];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            return Expanded(
              child: Container(height: 1, color: AppColors.borderGray),
            );
          }
          final i = index ~/ 2;
          final isActive = i == 0;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryBlue : AppColors.borderGray,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: GoogleFonts.inter(fontSize: 12, color: isActive ? AppColors.white : AppColors.textMuted, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[i],
                style: GoogleFonts.inter(fontSize: 12, color: isActive ? AppColors.primaryBlue : AppColors.textMuted),
              ),
            ],
          );
        }),
      ),
    );
  }
}