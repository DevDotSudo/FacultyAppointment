import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/shared/widgets/sidebar_nav_widget.dart';
import '../../../../features/shared/widgets/dashboard_header.dart';
import '../../../../features/shared/widgets/stat_card_widget.dart';
import '../../../../features/shared/widgets/dashboard_card.dart';
import '../../../../features/shared/widgets/appointment_tile.dart';
import '../../../../features/shared/widgets/quick_action_button.dart';
import '../../../../features/shared/widgets/appointment_status_badge.dart';
import '../../../../features/shared/widgets/responsive_layout.dart';
import '../cubit/student_cubit.dart';

class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StudentCubit()..loadDashboard(),
      child: BlocBuilder<StudentCubit, dynamic>(
        builder: (context, state) {
          if (state is StudentLoading) {
            return _buildLoading();
          }

          if (state is StudentLoaded) {
            return ResponsiveLayout(
              sidebar: _buildSidebar(context),
              header: DashboardHeader(
                name: 'John Doe',
                subtitle: 'Student',
                initials: 'JD',
              ),
              statCards: [
                StatCardWidget(
                  title: 'Total Appointments',
                  value: state.totalAppointments,
                  onViewAll: 'View all',
                  onViewAllTap: () => context.push('/student/my-appointments'),
                ),
                StatCardWidget(
                  title: 'Pending',
                  value: state.pending,
                  onViewAll: 'View all',
                  onViewAllTap: () => context.push('/student/my-appointments'),
                ),
                StatCardWidget(
                  title: 'Accepted',
                  value: state.accepted,
                  onViewAll: 'View all',
                  onViewAllTap: () => context.push('/student/my-appointments'),
                ),
                StatCardWidget(
                  title: 'Rejected',
                  value: state.rejected,
                  onViewAll: 'View all',
                  onViewAllTap: () => context.push('/student/my-appointments'),
                ),
              ],
              mainContent: DashboardCard(
                title: 'Upcoming Appointment',
                child: Column(
                  children: [
                    _buildUpcomingAppointment(state.upcomingAppointments[0]),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: () => context.push('/student/my-appointments'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'View All Appointments',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              quickActions: Column(
                children: [
                  QuickActionButton(
                    label: 'Book Appointment',
                    icon: Icons.add_circle_outline_rounded,
                    onTap: () => context.push('/student/book-appointment'),
                  ),
                  const SizedBox(height: 12),
                  QuickActionButton(
                    label: 'View Faculty Availability',
                    icon: Icons.calendar_view_day_rounded,
                    onTap: () => context.push('/student/faculty'),
                  ),
                ],
              ),
            );
          }

          return _buildLoading();
        },
      ),
    );
  }

  Widget _buildUpcomingAppointment(dynamic appointment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                appointment.facultyInitials,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.facultyName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      appointment.date,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time_rounded, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      appointment.time,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.purpose,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AppointmentStatusBadge(status: appointment.status),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return SidebarNavWidget(
      currentRoute: '/student/dashboard',
      items: [
        SidebarItem(
          label: 'Dashboard',
          icon: Icons.dashboard_rounded,
          route: '/student/dashboard',
          onTap: () {},
        ),
        SidebarItem(
          label: 'Faculty',
          icon: Icons.people_outline_rounded,
          route: '/student/faculty',
          onTap: () => context.push('/student/faculty'),
        ),
        SidebarItem(
          label: 'My Appointments',
          icon: Icons.calendar_month_rounded,
          route: '/student/my-appointments',
          onTap: () => context.push('/student/my-appointments'),
        ),
        SidebarItem(
          label: 'Profile',
          icon: Icons.person_outline_rounded,
          route: '/student/profile',
          onTap: () => context.push('/student/profile'),
        ),
      ],
      onLogout: () => context.push('/login'),
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}
