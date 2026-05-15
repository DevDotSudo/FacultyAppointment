import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/shared/widgets/sidebar_nav_widget.dart';
import '../../../../features/shared/widgets/dashboard_header.dart';
import '../../../../features/shared/widgets/stat_card_widget.dart';
import '../../../../features/shared/widgets/dashboard_card.dart';
import '../../../../features/shared/widgets/request_tile.dart';
import '../../../../features/shared/widgets/quick_action_button.dart';
import '../../../../features/shared/widgets/responsive_layout.dart';
import '../cubit/faculty_cubit.dart';

class FacultyDashboardPage extends StatelessWidget {
  const FacultyDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FacultyCubit()..loadDashboard(),
      child: BlocBuilder<FacultyCubit, dynamic>(
        builder: (context, state) {
          if (state is FacultyLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is FacultyLoaded) {
            return ResponsiveLayout(
              sidebar: _buildSidebar(context),
              header: DashboardHeader(
                name: 'Dr. Maria Santos',
                subtitle: 'Faculty',
                initials: 'MS',
              ),
              statCards: [
                StatCardWidget(
                  title: 'Total Requests',
                  value: state.totalRequests,
                  onViewAll: 'View all',
                  onViewAllTap: () => context.push('/faculty/requests'),
                ),
                StatCardWidget(
                  title: 'Pending',
                  value: state.pending,
                  onViewAll: 'View all',
                  onViewAllTap: () => context.push('/faculty/requests'),
                ),
                StatCardWidget(
                  title: 'Accepted',
                  value: state.accepted,
                  onViewAll: 'View all',
                  onViewAllTap: () => context.push('/faculty/requests'),
                ),
                StatCardWidget(
                  title: 'Rejected',
                  value: state.rejected,
                  onViewAll: 'View all',
                  onViewAllTap: () => context.push('/faculty/requests'),
                ),
              ],
              mainContent: DashboardCard(
                title: 'Pending Requests',
                child: Column(
                  children: [
                      ...state.pendingRequests.map((request) => RequestTile(
                            studentName: request.studentName,
                            initials: request.studentInitials,
                            date: request.date,
                            time: request.time,
                            onViewTap: () => context.push('/faculty/requests'),
                          )),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: () => context.push('/faculty/requests'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'View All Requests',
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
                    label: 'Manage Availability',
                    icon: Icons.timeline_rounded,
                    onTap: () => context.push('/faculty/availability'),
                  ),
                  const SizedBox(height: 12),
                    QuickActionButton(
                      label: 'View My Schedule',
                      icon: Icons.calendar_month_rounded,
                      onTap: () => context.push('/faculty/availability'),
                    ),
                ],
              ),
            );
          }

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return SidebarNavWidget(
      currentRoute: '/faculty/dashboard',
      items: [
        SidebarItem(
          label: 'Dashboard',
          icon: Icons.dashboard_rounded,
          route: '/faculty/dashboard',
          onTap: () {},
        ),
        SidebarItem(
          label: 'Requests',
          icon: Icons.mail_outline_rounded,
          route: '/faculty/requests',
          onTap: () => context.push('/faculty/requests'),
        ),
        SidebarItem(
          label: 'Availability',
          icon: Icons.calendar_today_rounded,
          route: '/faculty/availability',
          onTap: () => context.push('/faculty/availability'),
        ),
        SidebarItem(
          label: 'Profile',
          icon: Icons.person_outline_rounded,
          route: '/faculty/profile',
          onTap: () => context.push('/faculty/profile'),
        ),
      ],
      onLogout: () => context.push('/login'),
    );
  }
}
