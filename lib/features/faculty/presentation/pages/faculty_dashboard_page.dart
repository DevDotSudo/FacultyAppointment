import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../shared/widgets/dashboard_header.dart';
import '../../../shared/widgets/stat_card_widget.dart';
import '../../../shared/widgets/dashboard_card.dart';
import '../../../shared/widgets/quick_action_button.dart';
import '../../../shared/widgets/request_tile.dart';
import '../../../shared/widgets/dialog_helper.dart';
import '../../../shared/widgets/simple_chart.dart';

class FacultyDashboardPage extends StatelessWidget {
  const FacultyDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('faculty').doc(uid).get(),
      builder: (context, snapshot) {
        final fullName = snapshot.hasData && snapshot.data!.exists
            ? (snapshot.data!.get('full_name') as String? ?? 'Faculty')
            : 'Faculty';
        final initials = fullName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('appointment_requests')
              .where('faculty_id', isEqualTo: uid)
              .snapshots(),
          builder: (context, snap) {
            int total = 0, pending = 0, accepted = 0, rejected = 0;
            if (snap.hasData) {
              for (final doc in snap.data!.docs) {
                final s = doc['status'] as String? ?? '';
                total++;
                if (s == 'pending') { pending++; }
                else if (s == 'accepted') { accepted++; }
                else if (s == 'rejected') { rejected++; }
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardHeader(name: fullName, role: 'Faculty', initials: initials),
                const SizedBox(height: 24),

                // Stats
                LayoutBuilder(builder: (context, constraints) {
                  final twoCol = Responsive.statCardsTwoCol(constraints.maxWidth);
                  final cards = [
                    StatCardWidget(label: 'Total Requests', number: '$total', accentColor: AppColors.info, icon: Icons.inbox_rounded, onViewAll: () => context.goNamed('faculty-requests')),
                    StatCardWidget(label: 'Pending', number: '$pending', accentColor: AppColors.warning, icon: Icons.hourglass_empty_rounded, onViewAll: () => context.goNamed('faculty-requests')),
                    StatCardWidget(label: 'Accepted', number: '$accepted', accentColor: AppColors.success, icon: Icons.check_circle_outline_rounded),
                    StatCardWidget(label: 'Rejected', number: '$rejected', accentColor: AppColors.danger, icon: Icons.cancel_outlined),
                  ];
                  if (twoCol) {
                    return Column(children: [
                      Row(children: [
                        Expanded(child: cards[0]),
                        const SizedBox(width: 12),
                        Expanded(child: cards[1]),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: cards[2]),
                        const SizedBox(width: 12),
                        Expanded(child: cards[3]),
                      ]),
                    ]);
                  }
                  return Row(children: [
                    Expanded(child: cards[0]),
                    const SizedBox(width: 12),
                    Expanded(child: cards[1]),
                    const SizedBox(width: 12),
                    Expanded(child: cards[2]),
                    const SizedBox(width: 12),
                    Expanded(child: cards[3]),
                  ]);
                }),
                const SizedBox(height: 20),

                // Middle row
                LayoutBuilder(builder: (context, constraints) {
                  final isWide = Responsive.isTwoCol(constraints.maxWidth);

                  final pendingCard = StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('appointment_requests')
                        .where('faculty_id', isEqualTo: uid)
                        .where('status', isEqualTo: 'pending')
                        .orderBy('created_at', descending: true)
                        .limit(5)
                        .snapshots(),
                    builder: (context, pendingSnap) {
                      final docs = pendingSnap.hasData ? pendingSnap.data!.docs : <QueryDocumentSnapshot>[];
                      return DashboardCard(
                        title: 'Pending Requests',
                        titleIcon: Icons.pending_actions_rounded,
                        trailing: docs.isNotEmpty
                            ? TextButton(
                                onPressed: () => context.goNamed('faculty-requests'),
                                child: Text('View all', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                              )
                            : null,
                        child: docs.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(Icons.inbox_rounded, size: 32, color: isDark ? AppColors.darkMuted : AppColors.textMuted),
                                  const SizedBox(height: 8),
                                  Text('No pending requests', style: GoogleFonts.inter(
                                    color: isDark ? AppColors.darkMuted : AppColors.textMuted, fontSize: 13)),
                                ])),
                              )
                            : Column(
                                children: docs.map((doc) {
                                  final d = doc.data() as Map<String, dynamic>;
                                  return RequestTile(
                                    studentName: d['student_name'] as String? ?? 'Student',
                                    dateTime: '${d['date'] ?? ''} · ${d['time'] ?? ''}',
                                    purpose: d['purpose'] as String? ?? '',
                                    onAccept: () {
                                      FirebaseFirestore.instance.collection('appointment_requests').doc(doc.id).update({'status': 'accepted'});
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Request accepted ✓'), backgroundColor: AppColors.success));
                                    },
                                    onReject: () {
                                      FirebaseFirestore.instance.collection('appointment_requests').doc(doc.id).update({'status': 'rejected'});
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Request rejected'), backgroundColor: AppColors.danger));
                                    },
                                    onView: () => DialogHelper.showViewRequestModal(
                                      context,
                                      studentName: d['student_name'] as String? ?? 'Student',
                                      date: d['date'] as String? ?? '',
                                      time: d['time'] as String? ?? '',
                                      purpose: d['purpose'] as String? ?? '',
                                      onAccept: () {
                                        FirebaseFirestore.instance.collection('appointment_requests').doc(doc.id).update({'status': 'accepted'});
                                      },
                                      onReject: () {
                                        FirebaseFirestore.instance.collection('appointment_requests').doc(doc.id).update({'status': 'rejected'});
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                      );
                    },
                  );

                  final rightCol = Column(children: [
                    DashboardCard(
                      title: 'Quick Actions',
                      titleIcon: Icons.bolt_rounded,
                      child: Column(children: [
                        QuickActionButton(icon: Icons.schedule_rounded, label: 'Manage Availability',
                          onTap: () => context.goNamed('faculty-availability'), color: AppColors.primary),
                        const SizedBox(height: 8),
                        QuickActionButton(icon: Icons.inbox_rounded, label: 'All Requests',
                          onTap: () => context.goNamed('faculty-requests'), color: AppColors.warning),
                        const SizedBox(height: 8),
                        QuickActionButton(icon: Icons.person_outline_rounded, label: 'My Profile',
                          onTap: () => context.goNamed('faculty-profile'), color: AppColors.info),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    DashboardCard(
                      title: 'Request Overview',
                      titleIcon: Icons.pie_chart_outline_rounded,
                      child: total > 0
                          ? SimpleBarChart(bars: [
                              ChartBarData('Pending', pending.toDouble(), AppColors.warning),
                              ChartBarData('Accepted', accepted.toDouble(), AppColors.success),
                              ChartBarData('Rejected', rejected.toDouble(), AppColors.danger),
                            ])
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: Text('No data yet',
                                style: GoogleFonts.inter(color: isDark ? AppColors.darkMuted : AppColors.textMuted))),
                            ),
                    ),
                  ]);

                  if (isWide) {
                    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(flex: 2, child: pendingCard),
                      const SizedBox(width: 16),
                      Expanded(flex: 1, child: rightCol),
                    ]);
                  }
                  return Column(children: [pendingCard, const SizedBox(height: 16), rightCol]);
                }),
              ],
            );
          },
        );
      },
    );
  }
}
