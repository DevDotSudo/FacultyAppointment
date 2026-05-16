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
import '../../../shared/widgets/request_tile.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../../../shared/widgets/sidebar_nav_widget.dart';
import '../../../shared/widgets/dialog_helper.dart';
import '../../domain/usecases/accept_request_usecase.dart';
import '../../domain/usecases/reject_request_usecase.dart';
import '../cubit/faculty_cubit.dart';
import '../cubit/faculty_state.dart';

class FacultyDashboardPage extends StatelessWidget {
  const FacultyDashboardPage({super.key});

  List<SidebarNavItem> _sidebarItems(BuildContext context) => [
        SidebarNavItem(label: 'Dashboard', icon: Icons.dashboard, isActive: true, onTap: () => context.goNamed('faculty-dashboard')),
        SidebarNavItem(label: 'Requests', icon: Icons.list_alt, onTap: () => context.goNamed('faculty-requests')),
        SidebarNavItem(label: 'Availability', icon: Icons.calendar_today, onTap: () => context.goNamed('faculty-availability')),
        SidebarNavItem(label: 'Profile', icon: Icons.person, onTap: () => context.goNamed('faculty-profile')),
      ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      sidebarItems: _sidebarItems(context),
      onLogout: () => context.goNamed('login'),
      child: BlocBuilder<FacultyCubit, FacultyState>(
        builder: (context, state) {
          if (state is FacultyLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FacultyError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('faculty').doc(FirebaseAuth.instance.currentUser?.uid).get(),
            builder: (context, snapshot) {
              String fullName = 'Faculty';
              if (snapshot.hasData && snapshot.data!.exists) {
                fullName = snapshot.data!.get('full_name') as String? ?? 'Faculty';
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DashboardHeader(
                    name: fullName,
                    role: 'Faculty',
                    initials: fullName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase(),
                  ),
                  const SizedBox(height: 20),

                  if (state is FacultyLoaded) ...[
                    Row(
                      children: [
                        Expanded(child: StatCardWidget(label: 'Total Requests', number: state.totalRequests.toString(), onViewAll: () => context.goNamed('faculty-requests'))),
                        const SizedBox(width: 12),
                        Expanded(child: StatCardWidget(label: 'Pending', number: state.pending.toString(), onViewAll: () => context.goNamed('faculty-requests'))),
                        const SizedBox(width: 12),
                        Expanded(child: StatCardWidget(label: 'Accepted', number: state.accepted.toString(), onViewAll: () => context.goNamed('faculty-requests'))),
                        const SizedBox(width: 12),
                        Expanded(child: StatCardWidget(label: 'Rejected', number: state.rejected.toString(), onViewAll: () => context.goNamed('faculty-requests'))),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: DashboardCard(
                            title: 'Pending Requests',
                            child: state.pendingRequests.isEmpty
                                ? Padding(padding: const EdgeInsets.all(16), child: Text('No pending requests', style: GoogleFonts.inter(color: AppColors.textMuted)))
                                : Column(
                                    children: state.pendingRequests.map((req) => RequestTile(
                                      studentName: req.studentName,
                                      dateTime: '${req.date} · ${req.time}',
                                      purpose: 'Appointment request',
                                      onView: () {
                                        DialogHelper.showViewRequestModal(
                                          context,
                                          studentName: req.studentName,
                                          date: req.date,
                                          time: req.time,
                                          purpose: 'Appointment request',
                                          onAccept: () {
                                            DialogHelper.showAcceptRequestModal(
                                              context,
                                              studentName: req.studentName,
                                              date: req.date,
                                              time: req.time,
                                              onConfirm: () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Request accepted'), backgroundColor: AppColors.statusAccepted),
                                                );
                                              },
                                            );
                                          },
                                          onReject: () {
                                            DialogHelper.showRejectRequestModal(
                                              context,
                                              studentName: req.studentName,
                                              onConfirm: () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Request rejected'), backgroundColor: AppColors.statusRejected),
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                    )).toList(),
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
                                QuickActionButton(icon: Icons.calendar_today, label: 'Manage Availability', onTap: () => context.goNamed('faculty-availability')),
                                const SizedBox(height: 8),
                                QuickActionButton(icon: Icons.list_alt, label: 'View My Schedule', onTap: () => context.goNamed('faculty-availability')),
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
                        onPressed: () => context.goNamed('faculty-requests'),
                        child: const Text('View All Requests'),
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