import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../shared/widgets/stat_card_widget.dart';
import '../../../shared/widgets/dashboard_card.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('students').doc(uid).get(),
      builder: (context, snapshot) {
        final fullName = snapshot.hasData && snapshot.data!.exists
            ? (snapshot.data!.get('full_name') as String? ?? 'Student') : 'Student';

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('appointment_requests').where('student_id', isEqualTo: uid).snapshots(),
          builder: (context, snap) {
            int total = 0, pending = 0, accepted = 0, rejected = 0;
            if (snap.hasData) {
              for (final doc in snap.data!.docs) {
                final s = doc['status'] as String? ?? '';
                total++;
                if (s == 'pending') pending++;
                else if (s == 'accepted') accepted++;
                else if (s == 'rejected') rejected++;
              }
            }

            final statCardsTwoCol = Responsive.statCardsTwoCol(screenWidth);

            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Welcome header
              Text('Welcome, ${fullName.split(' ')[0]}',
                style: GoogleFonts.inter(
                  fontSize: Responsive.h2(screenWidth).fontSize,
                  fontWeight: FontWeight.w600,
                  color: textColor)),
              const SizedBox(height: 4),
              Text('Here\'s your appointment overview',
                style: GoogleFonts.inter(
                  fontSize: Responsive.body(screenWidth).fontSize,
                  color: mutedColor)),
              SizedBox(height: Responsive.s20),

              // ── Stats Grid ──
              // Mobile S/M: 2×2 grid; Mobile L+: 4-column row (scrollable if overflow)
              if (statCardsTwoCol) ...[
                Row(children: [
                  Expanded(child: StatCardWidget(label: 'Total', number: '$total', accentColor: AppColors.lightInfo, icon: Icons.calendar_month_rounded)),
                  SizedBox(width: Responsive.gutter(screenWidth)),
                  Expanded(child: StatCardWidget(label: 'Pending', number: '$pending', accentColor: AppColors.statusPending, icon: Icons.hourglass_empty_rounded)),
                ]),
                SizedBox(height: Responsive.gutter(screenWidth)),
                Row(children: [
                  Expanded(child: StatCardWidget(label: 'Accepted', number: '$accepted', accentColor: AppColors.statusAccepted, icon: Icons.check_circle_outline_rounded)),
                  SizedBox(width: Responsive.gutter(screenWidth)),
                  Expanded(child: StatCardWidget(label: 'Rejected', number: '$rejected', accentColor: AppColors.statusRejected, icon: Icons.cancel_outlined)),
                ]),
              ] else ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: (screenWidth - Responsive.outerPadding(screenWidth).horizontal * 2 - Responsive.gutter(screenWidth) * 3) / 4,
                        child: StatCardWidget(label: 'Total', number: '$total', accentColor: AppColors.lightInfo, icon: Icons.calendar_month_rounded),
                      ),
                      SizedBox(width: Responsive.gutter(screenWidth)),
                      SizedBox(
                        width: (screenWidth - Responsive.outerPadding(screenWidth).horizontal * 2 - Responsive.gutter(screenWidth) * 3) / 4,
                        child: StatCardWidget(label: 'Pending', number: '$pending', accentColor: AppColors.statusPending, icon: Icons.hourglass_empty_rounded),
                      ),
                      SizedBox(width: Responsive.gutter(screenWidth)),
                      SizedBox(
                        width: (screenWidth - Responsive.outerPadding(screenWidth).horizontal * 2 - Responsive.gutter(screenWidth) * 3) / 4,
                        child: StatCardWidget(label: 'Accepted', number: '$accepted', accentColor: AppColors.statusAccepted, icon: Icons.check_circle_outline_rounded),
                      ),
                      SizedBox(width: Responsive.gutter(screenWidth)),
                      SizedBox(
                        width: (screenWidth - Responsive.outerPadding(screenWidth).horizontal * 2 - Responsive.gutter(screenWidth) * 3) / 4,
                        child: StatCardWidget(label: 'Rejected', number: '$rejected', accentColor: AppColors.statusRejected, icon: Icons.cancel_outlined),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: Responsive.sectionGap(screenWidth)),

              // ── Chart + Quick Actions: responsive layout ──
              if (Responsive.isDesktop(screenWidth)) ...[
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 2, child: DashboardCard(
                    title: 'Overview', titleIcon: Icons.bar_chart_rounded,
                    child: total > 0 ? SizedBox(
                      height: 140,
                      child: SimpleBarChart(bars: [
                        ChartBarData('Pending', pending.toDouble(), AppColors.statusPending),
                        ChartBarData('Accepted', accepted.toDouble(), AppColors.statusAccepted),
                        ChartBarData('Rejected', rejected.toDouble(), AppColors.statusRejected),
                      ]),
                    ) : const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No data yet'))),
                  )),
                  SizedBox(width: Responsive.gutter(screenWidth)),
                  Expanded(flex: 1, child: DashboardCard(
                    title: 'Quick Actions', titleIcon: Icons.bolt_rounded,
                    child: Column(children: [
                      QuickActionButton(icon: Icons.add_circle_outline_rounded, label: 'Book Appointment',
                        onTap: () => context.goNamed('student-book-appointment'), color: AppColors.primary),
                      SizedBox(height: Responsive.s8),
                      QuickActionButton(icon: Icons.list_alt_rounded, label: 'My Appointments',
                        onTap: () => context.goNamed('student-my-appointments'), color: AppColors.lightInfo),
                      SizedBox(height: Responsive.s8),
                      QuickActionButton(icon: Icons.school_rounded, label: 'Browse Faculty',
                        onTap: () => context.goNamed('student-faculty'), color: AppColors.statusAccepted),
                      SizedBox(height: Responsive.s8),
                      QuickActionButton(icon: Icons.person_outline_rounded, label: 'My Profile',
                        onTap: () => context.goNamed('student-profile'), color: AppColors.statusPending),
                    ]),
                  )),
                ]),
              ] else ...[
                DashboardCard(
                  title: 'Overview', titleIcon: Icons.bar_chart_rounded,
                  child: total > 0 ? SizedBox(
                    height: 140,
                    child: SimpleBarChart(bars: [
                      ChartBarData('Pending', pending.toDouble(), AppColors.statusPending),
                      ChartBarData('Accepted', accepted.toDouble(), AppColors.statusAccepted),
                      ChartBarData('Rejected', rejected.toDouble(), AppColors.statusRejected),
                    ]),
                  ) : const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No data yet'))),
                ),
                SizedBox(height: Responsive.gutter(screenWidth)),
                DashboardCard(
                  title: 'Quick Actions', titleIcon: Icons.bolt_rounded,
                  child: Column(children: [
                    QuickActionButton(icon: Icons.add_circle_outline_rounded, label: 'Book Appointment',
                      onTap: () => context.goNamed('student-book-appointment'), color: AppColors.primary),
                    SizedBox(height: Responsive.s8),
                    QuickActionButton(icon: Icons.list_alt_rounded, label: 'My Appointments',
                      onTap: () => context.goNamed('student-my-appointments'), color: AppColors.lightInfo),
                    SizedBox(height: Responsive.s8),
                    QuickActionButton(icon: Icons.school_rounded, label: 'Browse Faculty',
                      onTap: () => context.goNamed('student-faculty'), color: AppColors.statusAccepted),
                    SizedBox(height: Responsive.s8),
                    QuickActionButton(icon: Icons.person_outline_rounded, label: 'My Profile',
                      onTap: () => context.goNamed('student-profile'), color: AppColors.statusPending),
                  ]),
                ),
              ],
              SizedBox(height: Responsive.sectionGap(screenWidth)),

              // ── Recent appointments ──
              DashboardCard(
                title: 'Recent Appointments', titleIcon: Icons.history_rounded,
                trailing: TextButton(onPressed: () => context.goNamed('student-my-appointments'),
                  child: Text('View all', style: GoogleFonts.inter(
                    fontSize: Responsive.small(screenWidth).fontSize,
                    color: AppColors.primary))),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('appointment_requests')
                      .where('student_id', isEqualTo: uid).orderBy('created_at', descending: true).limit(5).snapshots(),
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
                    if (items.isEmpty) return EmptyStateWidget(
                      icon: Icons.calendar_today_rounded, title: 'No appointments yet',
                      subtitle: 'Book your first appointment',
                      actionLabel: 'Book Now', onAction: () => context.goNamed('student-book-appointment'),
                    );
                    return Column(children: items.map((doc) {
                      final d = doc.data() as Map<String, dynamic>;
                      final status = d['status'] as String? ?? 'pending';
                      final facultyName = d['faculty_name'] as String? ?? 'Faculty';
                      return Padding(
                        padding: EdgeInsets.only(bottom: Responsive.s8),
                        child: Row(children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(child: Text(
                              facultyName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase(),
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary))),
                          ),
                          SizedBox(width: Responsive.s12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(facultyName, style: GoogleFonts.inter(
                              fontSize: Responsive.body(screenWidth).fontSize,
                              fontWeight: FontWeight.w600,
                              color: textColor)),
                            Text('${d['date'] ?? ''} · ${d['time'] ?? ''}',
                              style: GoogleFonts.inter(
                                fontSize: Responsive.small(screenWidth).fontSize,
                                color: mutedColor)),
                          ])),
                          AppointmentStatusBadge(status: status),
                        ]),
                      );
                    }).toList());
                  },
                ),
              ),
            ]);
          },
        );
      },
    );
  }
}