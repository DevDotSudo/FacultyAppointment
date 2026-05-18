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
import '../../../shared/widgets/request_tile.dart';
import '../../../shared/widgets/dialog_helper.dart';
import '../../../shared/widgets/simple_chart.dart';
import '../../domain/usecases/accept_request_usecase.dart';
import '../../domain/usecases/reject_request_usecase.dart';

class FacultyDashboardPage extends StatefulWidget {
  const FacultyDashboardPage({super.key});
  @override
  State<FacultyDashboardPage> createState() => _FacultyDashboardPageState();
}

class _FacultyDashboardPageState extends State<FacultyDashboardPage> {
  final _acceptUseCase = AcceptRequestUseCase();
  final _rejectUseCase = RejectRequestUseCase();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('faculty').doc(uid).get(),
      builder: (context, snapshot) {
        final fullName = snapshot.hasData && snapshot.data!.exists
            ? (snapshot.data!.get('full_name') as String? ?? 'Faculty') : 'Faculty';

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('appointment_requests').where('faculty_id', isEqualTo: uid).snapshots(),
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
              Text('Manage your appointment requests',
                style: GoogleFonts.inter(
                  fontSize: Responsive.body(screenWidth).fontSize,
                  color: mutedColor)),
              SizedBox(height: Responsive.s20),

              // ── Stats Grid ──
              if (statCardsTwoCol) ...[
                Row(children: [
                  Expanded(child: StatCardWidget(label: 'Total', number: '$total', accentColor: AppColors.lightInfo, icon: Icons.inbox_rounded, onViewAll: () => context.goNamed('faculty-requests'))),
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
                        child: StatCardWidget(label: 'Total', number: '$total', accentColor: AppColors.lightInfo, icon: Icons.inbox_rounded, onViewAll: () => context.goNamed('faculty-requests')),
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

              if (Responsive.isDesktop(screenWidth)) ...[
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 2, child: DashboardCard(
                    title: 'Pending Requests', titleIcon: Icons.pending_actions_rounded,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('appointment_requests')
                          .where('faculty_id', isEqualTo: uid).where('status', isEqualTo: 'pending')
                          .orderBy('created_at', descending: true).limit(5).snapshots(),
                      builder: (context, ps) {
                        final docs = ps.hasData ? ps.data!.docs : <QueryDocumentSnapshot>[];
                        if (docs.isEmpty) return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(child: Text('No pending requests', style: GoogleFonts.inter(color: mutedColor, fontSize: 13))),
                        );
                        return Column(children: docs.map((doc) {
                          final d = doc.data() as Map<String, dynamic>;
                          return RequestTile(
                            studentName: d['student_name'] as String? ?? 'Student',
                            dateTime: '${d['date'] ?? ''} · ${d['time'] ?? ''}',
                            purpose: d['purpose'] as String? ?? '',
                            onAccept: () async {
                              await _acceptUseCase.call(requestId: doc.id, studentId: d['student_id'] as String? ?? '');
                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Accepted')));
                            },
                            onReject: () async {
                              await _rejectUseCase.call(requestId: doc.id, studentId: d['student_id'] as String? ?? '');
                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rejected')));
                            },
                            onView: () => DialogHelper.showViewRequestModal(context,
                              studentName: d['student_name'] as String? ?? '', date: d['date'] as String? ?? '',
                              time: d['time'] as String? ?? '', purpose: d['purpose'] as String? ?? '',
                              onAccept: () async => await _acceptUseCase.call(requestId: doc.id, studentId: d['student_id'] as String? ?? ''),
                              onReject: () async => await _rejectUseCase.call(requestId: doc.id, studentId: d['student_id'] as String? ?? '')),
                          );
                        }).toList());
                      },
                    ),
                  )),
                  SizedBox(width: Responsive.gutter(screenWidth)),
                  Expanded(flex: 1, child: Column(children: [
                    DashboardCard(title: 'Quick Actions', titleIcon: Icons.bolt_rounded,
                      child: Column(children: [
                        QuickActionButton(icon: Icons.schedule_rounded, label: 'Manage Availability',
                          onTap: () => context.goNamed('faculty-availability'), color: AppColors.primary),
                        SizedBox(height: Responsive.s8),
                        QuickActionButton(icon: Icons.inbox_rounded, label: 'All Requests',
                          onTap: () => context.goNamed('faculty-requests'), color: AppColors.lightWarning),
                        SizedBox(height: Responsive.s8),
                        QuickActionButton(icon: Icons.person_outline_rounded, label: 'My Profile',
                          onTap: () => context.goNamed('faculty-profile'), color: AppColors.lightInfo),
                      ]),
                    ),
                    SizedBox(height: Responsive.gutter(screenWidth)),
                    DashboardCard(title: 'Overview', titleIcon: Icons.pie_chart_outline_rounded,
                      child: total > 0 ? SizedBox(
                        height: 120,
                        child: SimpleBarChart(bars: [
                          ChartBarData('Pending', pending.toDouble(), AppColors.statusPending),
                          ChartBarData('Accepted', accepted.toDouble(), AppColors.statusAccepted),
                          ChartBarData('Rejected', rejected.toDouble(), AppColors.statusRejected),
                        ]),
                      ) : const Padding(padding: EdgeInsets.all(16), child: Center(child: Text('No data yet'))),
                    ),
                  ])),
                ]),
              ] else ...[
                DashboardCard(
                  title: 'Pending Requests', titleIcon: Icons.pending_actions_rounded,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('appointment_requests')
                        .where('faculty_id', isEqualTo: uid).where('status', isEqualTo: 'pending')
                        .orderBy('created_at', descending: true).limit(5).snapshots(),
                    builder: (context, ps) {
                      final docs = ps.hasData ? ps.data!.docs : <QueryDocumentSnapshot>[];
                      if (docs.isEmpty) return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(child: Text('No pending requests', style: GoogleFonts.inter(color: mutedColor, fontSize: 13))),
                      );
                      return Column(children: docs.map((doc) {
                        final d = doc.data() as Map<String, dynamic>;
                        return RequestTile(
                          studentName: d['student_name'] as String? ?? 'Student',
                          dateTime: '${d['date'] ?? ''} · ${d['time'] ?? ''}',
                          purpose: d['purpose'] as String? ?? '',
                          onAccept: () async {
                            await _acceptUseCase.call(requestId: doc.id, studentId: d['student_id'] as String? ?? '');
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Accepted')));
                          },
                          onReject: () async {
                            await _rejectUseCase.call(requestId: doc.id, studentId: d['student_id'] as String? ?? '');
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rejected')));
                          },
                          onView: () => DialogHelper.showViewRequestModal(context,
                            studentName: d['student_name'] as String? ?? '', date: d['date'] as String? ?? '',
                            time: d['time'] as String? ?? '', purpose: d['purpose'] as String? ?? '',
                            onAccept: () async => await _acceptUseCase.call(requestId: doc.id, studentId: d['student_id'] as String? ?? ''),
                            onReject: () async => await _rejectUseCase.call(requestId: doc.id, studentId: d['student_id'] as String? ?? '')),
                        );
                      }).toList());
                    },
                  ),
                ),
                SizedBox(height: Responsive.gutter(screenWidth)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: DashboardCard(title: 'Quick Actions', titleIcon: Icons.bolt_rounded,
                    child: Column(children: [
                      QuickActionButton(icon: Icons.schedule_rounded, label: 'Manage Availability',
                        onTap: () => context.goNamed('faculty-availability'), color: AppColors.primary),
                      SizedBox(height: Responsive.s8),
                      QuickActionButton(icon: Icons.inbox_rounded, label: 'All Requests',
                        onTap: () => context.goNamed('faculty-requests'), color: AppColors.lightWarning),
                      SizedBox(height: Responsive.s8),
                      QuickActionButton(icon: Icons.person_outline_rounded, label: 'My Profile',
                        onTap: () => context.goNamed('faculty-profile'), color: AppColors.lightInfo),
                    ]),
                  )),
                  SizedBox(width: Responsive.gutter(screenWidth)),
                  Expanded(child: DashboardCard(title: 'Overview', titleIcon: Icons.pie_chart_outline_rounded,
                    child: total > 0 ? SizedBox(
                      height: 120,
                      child: SimpleBarChart(bars: [
                        ChartBarData('Pending', pending.toDouble(), AppColors.statusPending),
                        ChartBarData('Accepted', accepted.toDouble(), AppColors.statusAccepted),
                        ChartBarData('Rejected', rejected.toDouble(), AppColors.statusRejected),
                      ]),
                    ) : const Padding(padding: EdgeInsets.all(16), child: Center(child: Text('No data yet'))),
                  )),
                ]),
              ],
            ]);
          },
        );
      },
    );
  }
}