import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../shared/widgets/dashboard_header.dart';
import '../../../shared/widgets/dashboard_card.dart';
import '../../../shared/widgets/stat_card_widget.dart';
import '../../../shared/widgets/quick_action_button.dart';
import '../../../shared/widgets/appointment_status_badge.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/simple_chart.dart';

class StudentDashboardPage extends StatefulWidget {
  const StudentDashboardPage({super.key});

  @override
  State<StudentDashboardPage> createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('students').doc(uid).get(),
      builder: (context, snapshot) {
        final fullName = snapshot.hasData && snapshot.data!.exists
            ? (snapshot.data!.get('full_name') as String? ?? 'Student')
            : 'Student';
        final initials = fullName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('appointment_requests')
              .where('student_id', isEqualTo: uid)
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
                DashboardHeader(
                  name: fullName, role: 'Student', initials: initials,
                  searchHint: 'Search appointments...',
                  onSearch: (q) => setState(() => _searchQuery = q),
                ),
                const SizedBox(height: 24),

                // Stats row
                LayoutBuilder(builder: (context, constraints) {
                  final twoCol = Responsive.statCardsTwoCol(constraints.maxWidth);
                  final cards = [
                    StatCardWidget(label: 'Total', number: '$total', accentColor: AppColors.info, icon: Icons.calendar_month_rounded),
                    StatCardWidget(label: 'Pending', number: '$pending', accentColor: AppColors.warning, icon: Icons.hourglass_empty_rounded),
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
                  final chart = DashboardCard(
                    title: 'Appointment Overview',
                    titleIcon: Icons.bar_chart_rounded,
                    child: total > 0
                        ? SimpleBarChart(bars: [
                            ChartBarData('Pending', pending.toDouble(), AppColors.warning),
                            ChartBarData('Accepted', accepted.toDouble(), AppColors.success),
                            ChartBarData('Rejected', rejected.toDouble(), AppColors.danger),
                          ])
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: Text('No data yet',
                              style: GoogleFonts.inter(color: isDark ? AppColors.darkMuted : AppColors.textMuted))),
                          ),
                  );
                  final actions = DashboardCard(
                    title: 'Quick Actions',
                    titleIcon: Icons.bolt_rounded,
                    child: Column(children: [
                      QuickActionButton(icon: Icons.add_circle_outline_rounded, label: 'Book Appointment',
                        onTap: () => context.goNamed('student-book-appointment'), color: AppColors.primary),
                      const SizedBox(height: 8),
                      QuickActionButton(icon: Icons.list_alt_rounded, label: 'My Appointments',
                        onTap: () => context.goNamed('student-my-appointments'), color: AppColors.info),
                      const SizedBox(height: 8),
                      QuickActionButton(icon: Icons.school_rounded, label: 'Browse Faculty',
                        onTap: () => context.goNamed('student-faculty'), color: AppColors.success),
                      const SizedBox(height: 8),
                      QuickActionButton(icon: Icons.person_outline_rounded, label: 'My Profile',
                        onTap: () => context.goNamed('student-profile'), color: AppColors.warning),
                    ]),
                  );
                  if (isWide) {
                    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(flex: 2, child: chart),
                      const SizedBox(width: 16),
                      Expanded(flex: 1, child: actions),
                    ]);
                  }
                  return Column(children: [chart, const SizedBox(height: 16), actions]);
                }),
                const SizedBox(height: 20),

                // Recent appointments
                DashboardCard(
                  title: 'Recent Appointments',
                  titleIcon: Icons.history_rounded,
                  trailing: TextButton(
                    onPressed: () => context.goNamed('student-my-appointments'),
                    child: Text('View all', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('appointment_requests')
                        .where('student_id', isEqualTo: uid)
                        .orderBy('created_at', descending: true)
                        .limit(5)
                        .snapshots(),
                    builder: (context, recentSnap) {
                      if (!recentSnap.hasData) return const Center(child: CircularProgressIndicator());
                      var items = recentSnap.data!.docs;
                      if (_searchQuery.isNotEmpty) {
                        final q = _searchQuery.toLowerCase();
                        items = items.where((doc) {
                          final d = doc.data() as Map<String, dynamic>;
                          return (d['faculty_name'] as String? ?? '').toLowerCase().contains(q) ||
                              (d['status'] as String? ?? '').toLowerCase().contains(q);
                        }).toList();
                      }
                      if (items.isEmpty) {
                        return EmptyStateWidget(
                          icon: Icons.calendar_today_rounded,
                          title: 'No appointments yet',
                          subtitle: 'Book your first appointment with a faculty member',
                          actionLabel: 'Book Now',
                          onAction: () => context.goNamed('student-book-appointment'),
                        );
                      }
                      return Column(
                        children: items.map((doc) {
                          final d = doc.data() as Map<String, dynamic>;
                          final status = d['status'] as String? ?? 'pending';
                          final facultyName = d['faculty_name'] as String? ?? 'Faculty';
                          final initials2 = facultyName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(children: [
                              Container(
                                width: 38, height: 38,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(child: Text(initials2,
                                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary))),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(facultyName, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.darkText : AppColors.textDark)),
                                Text('${d['date'] ?? ''} · ${d['time'] ?? ''}',
                                  style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppColors.darkMuted : AppColors.textMuted)),
                              ])),
                              AppointmentStatusBadge(status: status),
                            ]),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
