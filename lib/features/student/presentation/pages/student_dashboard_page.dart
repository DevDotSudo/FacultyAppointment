import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../shared/widgets/appointment_status_badge.dart';
import '../../../shared/widgets/appointment_pie_chart.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/skeleton_loader.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────
class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('students').doc(uid).get(),
      builder: (context, userSnap) {
        final firstName = userSnap.hasData && userSnap.data!.exists
            ? (userSnap.data!.get('full_name') as String? ?? 'Student').split(' ').first
            : 'Student';

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
                if (s == 'pending') {
                  pending++;
                } else if (s == 'accepted') {
                  accepted++;
                } else if (s == 'rejected') {
                  rejected++;
                }
              }
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top bar ──
                  _TopBar(firstName: firstName, isDark: isDark, w: w),
                  SizedBox(height: Responsive.s24),

                  // ── Stat cards ──
                  LayoutBuilder(builder: (ctx, box) => _StatsRow(
                    availableWidth: box.maxWidth,
                    total: total, pending: pending,
                    accepted: accepted, rejected: rejected,
                    isDark: isDark,
                  )),
                  SizedBox(height: Responsive.sectionGap(w)),

                  // ── Middle section: chart + quick actions ──
                  _MiddleSection(
                    w: w, isDark: isDark,
                    total: total, pending: pending,
                    accepted: accepted, rejected: rejected,
                  ),
                  SizedBox(height: Responsive.sectionGap(w)),

                  // ── Upcoming appointment ──
                  _UpcomingCard(uid: uid, isDark: isDark, w: w),
                  SizedBox(height: Responsive.sectionGap(w)),

                  // ── Recent appointments ──
                  _RecentAppointmentsCard(uid: uid, isDark: isDark, w: w),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar: greeting + action buttons
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final String firstName;
  final bool isDark;
  final double w;
  const _TopBar({required this.firstName, required this.isDark, required this.w});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${_greeting()}, $firstName 👋',
          style: GoogleFonts.inter(
            fontSize: Responsive.h2(w).fontSize,
            fontWeight: FontWeight.w600,
            color: textColor)),
        const SizedBox(height: 3),
        Text('Here\'s your appointment overview',
          style: GoogleFonts.inter(
            fontSize: Responsive.body(w).fontSize,
            color: mutedColor)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats row
// ─────────────────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final double availableWidth;
  final int total, pending, accepted, rejected;
  final bool isDark;
  const _StatsRow({
    required this.availableWidth,
    required this.total, required this.pending,
    required this.accepted, required this.rejected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCardData('Total',    '$total',    Icons.calendar_month_rounded,      AppColors.primary,         AppColors.primaryBg,         const Color(0xFF4F46E5)),
      _StatCardData('Pending',  '$pending',  Icons.hourglass_top_rounded,       AppColors.statusPending,   AppColors.statusPendingBg,   AppColors.statusPendingText),
      _StatCardData('Accepted', '$accepted', Icons.check_circle_outline_rounded, AppColors.statusAccepted, AppColors.statusAcceptedBg,  AppColors.statusAcceptedText),
      _StatCardData('Rejected', '$rejected', Icons.cancel_outlined,             AppColors.statusRejected,  AppColors.statusRejectedBg,  AppColors.statusRejectedText),
    ];

    // Mobile: 2×2 grid; tablet+: 4-column row
    final gutter = Responsive.gutter(availableWidth);
    final twoCol = availableWidth < 600;
    final colCount = twoCol ? 2 : 4;
    final calculatedWidth = (availableWidth - gutter * (colCount - 1)) / colCount;
    final cardW = max(calculatedWidth, 120.0); // Minimum 120px per card

    return Wrap(
      spacing: gutter,
      runSpacing: gutter,
      children: cards.map((c) => SizedBox(
        width: cardW,
        child: _StatCard(data: c, isDark: isDark),
      )).toList(),
    );
  }
}

class _StatCardData {
  final String label, number;
  final IconData icon;
  final Color accent, bgColor, textColor;
  const _StatCardData(this.label, this.number, this.icon, this.accent, this.bgColor, this.textColor);
}

class _StatCard extends StatelessWidget {
  final _StatCardData data;
  final bool isDark;
  const _StatCard({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Container(
      padding: Responsive.cardPadding(w),
      decoration: BoxDecoration(
        color: data.accent,  // Colored background!
        borderRadius: BorderRadius.circular(Responsive.cardRadius(w)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(data.label,
                style: GoogleFonts.inter(
                  fontSize: Responsive.small(w).fontSize,
                  color: Colors.white.withValues(alpha: 0.9))),
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(data.icon, size: 15,
                  color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(data.number,
            style: GoogleFonts.inter(
              fontSize: (Responsive.h2(w).fontSize ?? 20) + 4,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1)),
          const SizedBox(height: 2),
          Text('appointments',
            style: GoogleFonts.inter(
              fontSize: (Responsive.small(w).fontSize ?? 12) - 1,
              color: Colors.white.withValues(alpha: 0.85))),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Middle section: overview chart + quick actions (side by side on tablet+)
// ─────────────────────────────────────────────────────────────────────────────
class _MiddleSection extends StatelessWidget {
  final double w;
  final bool isDark;
  final int total, pending, accepted, rejected;
  const _MiddleSection({
    required this.w, required this.isDark,
    required this.total, required this.pending,
    required this.accepted, required this.rejected,
  });

  @override
  Widget build(BuildContext context) {
    final gutter = Responsive.gutter(w);
    final overview = _OverviewCard(
      total: total, pending: pending,
      accepted: accepted, rejected: rejected,
      isDark: isDark, w: w,
    );
    final quickActions = _QuickActionsCard(isDark: isDark, w: w);

    if (Responsive.isMobile(w)) {
      return Column(
        children: [
          overview,
          SizedBox(height: gutter),
          quickActions,
        ],
      );
    }

    // Tablet and desktop: side by side (chart 3/5, actions 2/5)
    return LayoutBuilder(builder: (ctx, box) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: overview),
          SizedBox(width: gutter),
          Expanded(flex: 2, child: quickActions),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Overview card: pie chart (same as faculty)
// ─────────────────────────────────────────────────────────────────────────────
class _OverviewCard extends StatelessWidget {
  final int total, pending, accepted, rejected;
  final bool isDark;
  final double w;
  const _OverviewCard({
    required this.total, required this.pending,
    required this.accepted, required this.rejected,
    required this.isDark, required this.w,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      isDark: isDark, w: w,
      title: 'Overview',
      icon: Icons.pie_chart_outline_rounded,
      child: AppointmentPieChart(
        pending: pending,
        approved: accepted,
        rejected: rejected,
        completed: 0,
        cancelled: 0,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick actions card
// ─────────────────────────────────────────────────────────────────────────────
class _QuickActionsCard extends StatelessWidget {
  final bool isDark;
  final double w;
  const _QuickActionsCard({required this.isDark, required this.w});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QAData('Book Appointment', Icons.add_circle_outline_rounded,
        AppColors.primary,         AppColors.primaryBg,         'student-faculty'),
      _QAData('My Appointments',  Icons.list_alt_rounded,
        AppColors.info,            AppColors.infoBg,            'student-my-appointments'),
      _QAData('Browse Faculty',   Icons.people_alt_rounded,
        AppColors.statusAccepted,  AppColors.successBg,         'student-faculty'),
      _QAData('My Profile',       Icons.person_outline_rounded,
        AppColors.statusPending,   AppColors.warningBg,         'student-profile'),
    ];

    return _Card(
      isDark: isDark, w: w,
      title: 'Quick Actions',
      icon: Icons.bolt_rounded,
      child: Column(
        children: actions.map((a) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _QAButton(data: a, isDark: isDark, w: w),
        )).toList(),
      ),
    );
  }
}

class _QAData {
  final String label, routeName;
  final IconData icon;
  final Color color, bgColor;
  const _QAData(this.label, this.icon, this.color, this.bgColor, this.routeName);
}

class _QAButton extends StatelessWidget {
  final _QAData data;
  final bool isDark;
  final double w;
  const _QAButton({required this.data, required this.isDark, required this.w});

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark
      ? data.color.withValues(alpha: 0.2)
      : data.color.withValues(alpha: 0.15);
    final fillColor = isDark
      ? data.color.withValues(alpha: 0.1)
      : data.bgColor;
    
    // Responsive font size for smaller screens
    final fontSize = w < 900 ? 12.0 : Responsive.body(w).fontSize ?? 14.0;
    final iconSize = w < 900 ? 15.0 : 17.0;

    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: () => context.goNamed(data.routeName),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: w < 900 ? 8 : Responsive.gutter(w) * 0.5,
            vertical: w < 900 ? 8 : 10,
          ),
          decoration: BoxDecoration(
            color: fillColor,
            border: Border.all(color: borderColor, width: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(data.icon, size: iconSize, color: data.color),
              SizedBox(width: w < 900 ? 6 : 10),
              Expanded(
                child: Text(
                  data.label,
                  style: GoogleFonts.inter(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    color: data.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios_rounded, size: 11,
                color: data.color.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Upcoming appointment reminder card
// ─────────────────────────────────────────────────────────────────────────────
class _UpcomingCard extends StatelessWidget {
  final String uid;
  final bool isDark;
  final double w;
  const _UpcomingCard({required this.uid, required this.isDark, required this.w});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointment_requests')
          .where('student_id', isEqualTo: uid)
          .where('status', isEqualTo: 'accepted')
          .limit(1)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.docs.isEmpty) return const SizedBox.shrink();
        final d = snap.data!.docs.first.data() as Map<String, dynamic>;
        final faculty = d['faculty_name'] as String? ?? 'Faculty';
        final date = d['date'] as String? ?? '';
        final time = d['time'] as String? ?? '';
        final purpose = d['purpose'] as String? ?? '';

        return Container(
          width: double.infinity,
          padding: Responsive.cardPadding(w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.primary.withValues(alpha: 0.25), const Color(0xFF6366F1).withValues(alpha: 0.15)]
                  : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(Responsive.cardRadius(w)),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.event_available_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Upcoming Appointment',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                      color: AppColors.primary, letterSpacing: 0.3)),
              const SizedBox(height: 3),
              Text(faculty,
                  style: GoogleFonts.inter(fontSize: Responsive.body(w).fontSize,
                      fontWeight: FontWeight.w600, color: textColor)),
              const SizedBox(height: 2),
              Text([if (date.isNotEmpty) date, if (time.isNotEmpty) time].join(' · '),
                  style: GoogleFonts.inter(fontSize: Responsive.small(w).fontSize, color: mutedColor)),
              if (purpose.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(purpose,
                    style: GoogleFonts.inter(fontSize: Responsive.small(w).fontSize, color: mutedColor),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ])),
            Icon(Icons.chevron_right_rounded, color: AppColors.primary.withValues(alpha: 0.6)),
          ]),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recent appointments card
// ─────────────────────────────────────────────────────────────────────────────
class _RecentAppointmentsCard extends StatelessWidget {
  final String uid;
  final bool isDark;
  final double w;
  const _RecentAppointmentsCard({required this.uid, required this.isDark, required this.w});

  @override
  Widget build(BuildContext context) {
    return _Card(
      isDark: isDark, w: w,
      title: 'Recent Appointments',
      icon: Icons.history_rounded,
      trailing: TextButton(
        onPressed: () => context.goNamed('student-my-appointments'),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text('View all →',
          style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.primary)),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointment_requests')
            .where('student_id', isEqualTo: uid)
            .limit(5)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: Responsive.s24),
              child: Center(child: Text('Failed to load appointments.',
                  style: GoogleFonts.inter(fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary))),
            );
          }
          if (!snap.hasData) {
            // Show skeleton loaders
            return Column(
              children: List.generate(
                3,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: index < 2 ? 16 : 0),
                  child: const SkeletonAppointmentTile(),
                ),
              ),
            );
          }
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.calendar_today_rounded,
              title: 'No appointments yet',
              subtitle: 'Book your first appointment below',
              actionLabel: 'Book Now',
              onAction: () => context.goNamed('student-book-appointment'),
            );
          }

          return Column(
            children: docs.asMap().entries.map((entry) {
              final i = entry.key;
              final doc = entry.value;
              final d = doc.data() as Map<String, dynamic>;
              final status = d['status'] as String? ?? 'pending';
              final facultyName = d['faculty_name'] as String? ?? 'Faculty';
              final initials = facultyName
                  .split(' ')
                  .map((e) => e.isNotEmpty ? e[0] : '')
                  .take(2).join().toUpperCase();
              final isLast = i == docs.length - 1;

              return Column(
                children: [
                  _AppointmentRow(
                    initials: initials,
                    facultyName: facultyName,
                    date: d['date'] as String? ?? '',
                    time: d['time'] as String? ?? '',
                    status: status,
                    isDark: isDark,
                    w: w,
                  ),
                  if (!isLast)
                    Divider(
                      height: 16,
                      color: isDark ? AppColors.darkBorder : AppColors.dividerLight,
                      thickness: 0.5,
                    ),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _AppointmentRow extends StatelessWidget {
  final String initials, facultyName, date, time, status;
  final bool isDark;
  final double w;
  const _AppointmentRow({
    required this.initials, required this.facultyName,
    required this.date, required this.time, required this.status,
    required this.isDark, required this.w,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Row(
      children: [
        // Initials avatar
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: isDark
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.primaryBg,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: Text(initials,
              style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: AppColors.primary)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(facultyName,
                style: GoogleFonts.inter(
                  fontSize: Responsive.body(w).fontSize,
                  fontWeight: FontWeight.w600,
                  color: textColor)),
              const SizedBox(height: 2),
              Text(
                [if (date.isNotEmpty) date, if (time.isNotEmpty) time].join(' · '),
                style: GoogleFonts.inter(
                  fontSize: Responsive.small(w).fontSize,
                  color: mutedColor)),
            ],
          ),
        ),
        AppointmentStatusBadge(status: status),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared card container
// ─────────────────────────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final bool isDark;
  final double w;
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;
  const _Card({
    required this.isDark, required this.w,
    required this.title, required this.icon,
    required this.child, this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.darkCard : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      width: double.infinity,
      padding: Responsive.cardPadding(w),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: borderColor, width: 0.5),
        borderRadius: BorderRadius.circular(Responsive.cardRadius(w)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: mutedColor),
              const SizedBox(width: 7),
              Text(title,
                style: GoogleFonts.inter(
                  fontSize: Responsive.h4(w).fontSize,
                  fontWeight: FontWeight.w600,
                  color: textColor)),
              const Spacer(),
              ?trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

String _greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}
