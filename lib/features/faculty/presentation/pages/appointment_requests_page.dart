import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/request_tile.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../../../shared/widgets/sidebar_nav_widget.dart';
import '../../../shared/widgets/dialog_helper.dart';

class AppointmentRequestsPage extends StatefulWidget {
  const AppointmentRequestsPage({super.key});

  @override
  State<AppointmentRequestsPage> createState() => _AppointmentRequestsPageState();
}

class _AppointmentRequestsPageState extends State<AppointmentRequestsPage> {
  String _selectedTab = 'Pending';
  final List<String> _tabs = ['Pending', 'Accepted', 'Rejected', 'Cancelled'];

  List<SidebarNavItem> _sidebarItems(BuildContext context) => [
        SidebarNavItem(label: 'Dashboard', icon: Icons.dashboard, onTap: () => context.goNamed('faculty-dashboard')),
        SidebarNavItem(label: 'Requests', icon: Icons.list_alt, isActive: true, onTap: () => context.goNamed('faculty-requests')),
        SidebarNavItem(label: 'Availability', icon: Icons.calendar_today, onTap: () => context.goNamed('faculty-availability')),
        SidebarNavItem(label: 'Profile', icon: Icons.person, onTap: () => context.goNamed('faculty-profile')),
      ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      sidebarItems: _sidebarItems(context),
      onLogout: () => context.goNamed('login'),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointment_requests')
            .where('faculty_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid ?? '')
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

          final filtered = _selectedTab == 'Pending'
              ? requests.where((r) => r['status'] == 'pending').toList()
              : _selectedTab == 'Accepted'
                  ? requests.where((r) => r['status'] == 'accepted').toList()
                  : _selectedTab == 'Rejected'
                      ? requests.where((r) => r['status'] == 'rejected').toList()
                      : requests.where((r) => r['status'] == 'cancelled').toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Appointment Requests', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 16),

              Container(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.borderGray))),
                child: Row(
                  children: _tabs.map((tab) {
                    final isActive = tab == _selectedTab;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTab = tab),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: isActive ? AppColors.primaryBlue : Colors.transparent, width: 2)),
                        ),
                        child: Text(tab, style: GoogleFonts.inter(fontSize: 13, color: isActive ? AppColors.primaryBlue : AppColors.textMuted, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(child: Text('No ${_selectedTab.toLowerCase()} requests', style: GoogleFonts.inter(color: AppColors.textMuted))),
                )
              else
                ...filtered.map((req) => RequestTile(
                      studentName: req['student_name'] as String? ?? 'Unknown',
                      dateTime: '${req['date'] ?? ''} · ${req['time'] ?? ''}',
                      purpose: req['purpose'] as String? ?? '',
                      onView: () {
                        DialogHelper.showViewRequestModal(
                          context,
                          studentName: req['student_name'] as String? ?? 'Unknown',
                          date: req['date'] as String? ?? '',
                          time: req['time'] as String? ?? '',
                          purpose: req['purpose'] as String? ?? '',
                          onAccept: () {
                            DialogHelper.showAcceptRequestModal(
                              context,
                              studentName: req['student_name'] as String? ?? 'Unknown',
                              date: req['date'] as String? ?? '',
                              time: req['time'] as String? ?? '',
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
                              studentName: req['student_name'] as String? ?? 'Unknown',
                              onConfirm: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Request rejected'), backgroundColor: AppColors.statusRejected),
                                );
                              },
                            );
                          },
                        );
                      },
                    )),

              const SizedBox(height: 16),
              Text('Showing 1 to ${filtered.length} of ${filtered.length} entries', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
            ],
          );
        },
      ),
    );
  }
}