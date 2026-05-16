import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/appointment_tile.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../../../shared/widgets/sidebar_nav_widget.dart';
import '../../../shared/widgets/dialog_helper.dart';
import '../../../shared/widgets/dashboard_header.dart';
import '../../domain/usecases/cancel_appointment_usecase.dart';

class MyAppointmentsPage extends StatefulWidget {
  const MyAppointmentsPage({super.key});

  @override
  State<MyAppointmentsPage> createState() => _MyAppointmentsPageState();
}

class _MyAppointmentsPageState extends State<MyAppointmentsPage> {
  String _selectedTab = 'All';
  final List<String> _tabs = ['All', 'Pending', 'Accepted', 'Rejected', 'Cancelled'];
  final CancelAppointmentUseCase _cancelUseCase = CancelAppointmentUseCase();

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      sidebarItems: [
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
      ],
      onLogout: () => context.goNamed('login'),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointment_requests')
            .where('student_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid ?? '')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var requests = snapshot.data!.docs.map((doc) {
            final d = doc.data() as Map<String, dynamic>;
            return {'id': doc.id, ...d};
          }).toList();

          if (_selectedTab != 'All') {
            requests = requests.where((r) => (r['status'] as String).toLowerCase() == _selectedTab.toLowerCase()).toList();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('students')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .get(),
                builder: (context, snap) {
                  String fullName = 'Student';
                  if (snap.hasData && snap.data!.exists) {
                    fullName = snap.data!.get('full_name') as String? ?? 'Student';
                  }
                  return DashboardHeader(
                    name: fullName,
                    role: 'Student',
                    initials: fullName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase(),
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                'My Appointments',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 16),

              // Tabs
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.borderGray)),
                ),
                child: Row(
                  children: _tabs.map((tab) {
                    final isActive = tab == _selectedTab;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTab = tab),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isActive ? AppColors.primaryBlue : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          tab,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: isActive ? AppColors.primaryBlue : AppColors.textMuted,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              if (requests.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('No appointments found')),
                )
              else
                ...requests.map((appt) => AppointmentTile(
                      name: appt['faculty_name'] as String? ?? 'Unknown',
                      dateTime: '${appt['date'] ?? ''} · ${appt['time'] ?? ''}',
                      purpose: appt['purpose'] as String? ?? '',
                      status: appt['status'] as String? ?? 'pending',
                      actionButton: (appt['status'] == 'pending')
                          ? TextButton(
                              onPressed: () {
                                DialogHelper.showCancelAppointmentModal(
                                  context,
                                  facultyName: appt['faculty_name'] as String? ?? 'Faculty',
                                  onConfirm: () async {
                                    try {
                                      await _cancelUseCase.call(requestId: appt['id'] as String);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Appointment cancelled'), backgroundColor: AppColors.statusRejected),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                        );
                                      }
                                    }
                                  },
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.statusRejected,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text('Cancel', style: GoogleFonts.inter(fontSize: 12)),
                            )
                          : null,
                    )),

              const SizedBox(height: 16),
              Text(
                'Showing 1 to ${requests.length} of ${requests.length} entries',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
              ),
            ],
          );
        },
      ),
    );
  }
}