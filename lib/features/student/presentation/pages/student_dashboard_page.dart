import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/dashboard_header.dart';
import '../../../shared/widgets/stat_card_widget.dart';
import '../../../shared/widgets/dashboard_card.dart';
import '../../../shared/widgets/quick_action_button.dart';
import '../../../shared/widgets/appointment_status_badge.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../../../shared/widgets/sidebar_nav_widget.dart';
import '../cubit/student_cubit.dart';
import '../cubit/student_state.dart';

class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key});

  List<SidebarNavItem> _sidebarItems(BuildContext context) => [
        SidebarNavItem(
          label: 'Dashboard',
          icon: Icons.dashboard,
          isActive: true,
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
      child: BlocBuilder<StudentCubit, StudentState>(
        builder: (context, state) {
          if (state is StudentLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StudentError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          // Fetch real name from Firestore
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('students')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .get(),
            builder: (context, snapshot) {
              String fullName = 'Student';
              if (snapshot.hasData && snapshot.data!.exists) {
                fullName = snapshot.data!.get('full_name') as String? ?? 'Student';
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DashboardHeader(
                    name: fullName,
                    role: 'Student',
                    initials: fullName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase(),
                  ),
                  const SizedBox(height: 20),

                  if (state is StudentLoaded) ...[
                    // Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: StatCardWidget(
                            label: 'Total Appointments',
                            number: state.totalAppointments.toString(),
                            onViewAll: () => context.goNamed('student-my-appointments'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCardWidget(
                            label: 'Pending',
                            number: state.pending.toString(),
                            onViewAll: () => context.goNamed('student-my-appointments'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCardWidget(
                            label: 'Accepted',
                            number: state.accepted.toString(),
                            onViewAll: () => context.goNamed('student-my-appointments'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCardWidget(
                            label: 'Rejected',
                            number: state.rejected.toString(),
                            onViewAll: () => context.goNamed('student-my-appointments'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Upcoming Appointment
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: DashboardCard(
                            title: 'Upcoming Appointment',
                            child: state.upcomingAppointments.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      'No upcoming appointments',
                                      style: GoogleFonts.inter(color: AppColors.textMuted),
                                    ),
                                  )
                                : Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: AppColors.primaryBlue,
                                        child: Text(
                                          state.upcomingAppointments.first.facultyInitials,
                                          style: GoogleFonts.inter(color: AppColors.white, fontSize: 12),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              state.upcomingAppointments.first.facultyName,
                                              style: GoogleFonts.inter(
                                                fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark,
                                              ),
                                            ),
                                            Text(
                                              '${state.upcomingAppointments.first.date} · ${state.upcomingAppointments.first.time}',
                                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                                            ),
                                            Text(
                                              state.upcomingAppointments.first.purpose,
                                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                                            ),
                                          ],
                                        ),
                                      ),
                                      AppointmentStatusBadge(status: state.upcomingAppointments.first.status),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DashboardCard(
                            title: 'Quick Actions',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                QuickActionButton(
                                  icon: Icons.calendar_today,
                                  label: 'Book Appointment',
                                  onTap: () => context.goNamed('student-book-appointment'),
                                ),
                                const SizedBox(height: 8),
                                QuickActionButton(
                                  icon: Icons.visibility,
                                  label: 'View Faculty Availability',
                                  onTap: () => context.goNamed('student-faculty'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.goNamed('student-my-appointments'),
                        child: const Text('View All Appointments'),
                      ),
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}