import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../shared/widgets/appointment_pie_chart.dart';
import '../../../shared/widgets/request_tile.dart';
import '../../../shared/widgets/dialog_helper.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../domain/usecases/accept_request_usecase.dart';
import '../../domain/usecases/reject_request_usecase.dart';
import '../../../../core/utils/encryption_service.dart';

class FacultyDashboardPage extends StatefulWidget {
  const FacultyDashboardPage({super.key});
  @override
  State<FacultyDashboardPage> createState() => _FacultyDashboardPageState();
}

class _FacultyDashboardPageState extends State<FacultyDashboardPage> {
  final _accept = AcceptRequestUseCase();
  final _reject = RejectRequestUseCase();
  late final Future<DocumentSnapshot> _nameFuture;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    _nameFuture = FirebaseFirestore.instance.collection('faculty').doc(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return FutureBuilder<DocumentSnapshot>(
      future: _nameFuture,
      builder: (context, snap) {
        final name = snap.hasData && snap.data!.exists
            ? (snap.data!.get('full_name') as String? ?? 'Faculty').split(' ').first
            : 'Faculty';

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('appointment_requests')
              .where('faculty_id', isEqualTo: uid)
              .snapshots(),
          builder: (context, apSnap) {
            if (apSnap.hasError) {
              return Center(child: Text('Failed to load data.',
                  style: GoogleFonts.inter(color: mutedColor)));
            }
            int pending = 0, approved = 0, rejected = 0, completed = 0, cancelled = 0;
            if (apSnap.hasData) {
              for (final doc in apSnap.data!.docs) {
                final s = (doc['status'] as String? ?? '').toLowerCase();
                if (s == 'pending') { pending++; }
                else if (s == 'accepted') { approved++; }
                else if (s == 'rejected') { rejected++; }
                else if (s == 'completed') { completed++; }
                else if (s == 'cancelled') { cancelled++; }
              }
            }

            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Greeting
              Text('${_greeting()}, $name 👋',
                  style: GoogleFonts.inter(fontSize: Responsive.h2(w).fontSize,
                      fontWeight: FontWeight.w600, color: textColor)),
              const SizedBox(height: 2),
              Text('Here\'s your appointment overview',
                  style: GoogleFonts.inter(fontSize: Responsive.body(w).fontSize, color: mutedColor)),
              SizedBox(height: Responsive.sectionGap(w)),

              // Stat cards
              LayoutBuilder(builder: (_, box) {
                final cols = box.maxWidth < 400 ? 2 : box.maxWidth < 700 ? 3 : 5;
                final gutter = Responsive.gutter(w);
                final totalGutter = gutter * (cols - 1);
                final cardW = totalGutter >= box.maxWidth 
                    ? (box.maxWidth / cols) 
                    : (box.maxWidth - totalGutter) / cols;
                final stats = [
                  _Stat('Pending',   pending,   AppColors.statusPending,  Icons.hourglass_empty_rounded),
                  _Stat('Approved',  approved,  AppColors.statusAccepted, Icons.check_circle_outline_rounded),
                  _Stat('Completed', completed, const Color(0xFF6366F1),  Icons.task_alt_rounded),
                  _Stat('Rejected',  rejected,  AppColors.statusRejected, Icons.cancel_outlined),
                ];
                return Wrap(spacing: gutter, runSpacing: gutter,
                  children: stats.map((s) => SizedBox(width: cardW,
                    child: _StatCard(stat: s, isDark: isDark))).toList());
              }),
              SizedBox(height: Responsive.sectionGap(w)),

              // Middle section: chart + quick actions (side by side on tablet+)
              LayoutBuilder(builder: (_, box) {
                final gutter = Responsive.gutter(w);
                final overview = _OverviewCard(pending: pending, approved: approved,
                    rejected: rejected, completed: completed, cancelled: cancelled, isDark: isDark);
                final quickActions = _QuickActionsCard(isDark: isDark);

                if (box.maxWidth >= 700) {
                  return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(flex: 3, child: overview),
                    SizedBox(width: gutter),
                    Expanded(flex: 2, child: quickActions),
                  ]);
                }
                return Column(children: [
                  overview,
                  SizedBox(height: gutter),
                  quickActions,
                ]);
              }),
              SizedBox(height: Responsive.sectionGap(w)),

              // Today's schedule
              _TodayScheduleCard(uid: uid, isDark: isDark, mutedColor: mutedColor),
              SizedBox(height: Responsive.sectionGap(w)),

              // Pending requests
              _PendingCard(uid: uid, isDark: isDark,
                  accept: _accept, reject: _reject, mutedColor: mutedColor),
            ]);
          },
        );
      },
    );
  }
}

// ── Stat card ──────────────────────────────────────────────────────────────
class _Stat {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  const _Stat(this.label, this.count, this.color, this.icon);
}

class _StatCard extends StatelessWidget {
  final _Stat stat;
  final bool isDark;
  const _StatCard({required this.stat, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: stat.color,  // Colored background!
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text(stat.label,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.9)),
              overflow: TextOverflow.ellipsis)),
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(stat.icon, size: 14, color: Colors.white),
          ),
        ]),
        const SizedBox(height: 8),
        Text('${stat.count}',
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700,
                color: Colors.white)),
      ]),
    );
  }
}

// ── Today's schedule card ──────────────────────────────────────────────────
class _TodayScheduleCard extends StatelessWidget {
  final String uid;
  final bool isDark;
  final Color mutedColor;
  const _TodayScheduleCard({required this.uid, required this.isDark, required this.mutedColor});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return _Card(
      isDark: isDark,
      title: "Today's Schedule",
      icon: Icons.today_rounded,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointment_requests')
            .where('faculty_id', isEqualTo: uid)
            .where('status', isEqualTo: 'accepted')
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return Column(
              children: List.generate(
                2,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: index < 1 ? 8 : 0),
                  child: const SkeletonAppointmentTile(),
                ),
              ),
            );
          }

          // Filter client-side for today — try multiple formats for robustness
          final todayFormats = [
            DateFormat('EEE, MMM d, yyyy').format(now),
            DateFormat('M/d/yyyy').format(now),
            DateFormat('MM/dd/yyyy').format(now),
            DateFormat('yyyy-MM-dd').format(now),
          ];
          final docs = snap.data!.docs
              .where((d) => todayFormats.contains(d['date'] as String? ?? ''))
              .toList()
            ..sort((a, b) => _parseTime(a['time'] as String? ?? '')
                .compareTo(_parseTime(b['time'] as String? ?? '')));

          if (docs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(children: [
                Icon(Icons.check_circle_outline_rounded, size: 18, color: AppColors.success),
                const SizedBox(width: 8),
                Text('No appointments scheduled for today',
                    style: GoogleFonts.inter(fontSize: 13, color: mutedColor)),
              ]),
            );
          }

          return Column(children: docs.map((doc) {
            final d = EncryptionService.decryptFields(doc.data() as Map<String, dynamic>);
            final student = d['student_name'] as String? ?? 'Student';
            final time = d['time'] as String? ?? '';
            final purpose = d['purpose'] as String? ?? '';
            final initials = student.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(child: Text(initials,
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700,
                          color: AppColors.primary))),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(student, style: GoogleFonts.inter(fontSize: 13,
                      fontWeight: FontWeight.w600, color: textColor)),
                  if (time.isNotEmpty)
                    Text(time, style: GoogleFonts.inter(fontSize: 12, color: mutedColor)),
                  if (purpose.isNotEmpty)
                    Text(purpose, style: GoogleFonts.inter(fontSize: 12, color: mutedColor),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.statusAccepted.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text('Confirmed', style: GoogleFonts.inter(fontSize: 11,
                      fontWeight: FontWeight.w600, color: AppColors.statusAccepted)),
                ),
              ]),
            );
          }).toList());
        },
      ),
    );
  }

  /// Converts "9:00 AM" / "10:30 PM" to minutes-since-midnight for correct sorting.
  int _parseTime(String t) {
    try {
      final dt = DateFormat('h:mm a').parse(t.trim());
      return dt.hour * 60 + dt.minute;
    } catch (_) {
      return 0;
    }
  }
}

// ── Pending requests card ──────────────────────────────────────────────────
class _PendingCard extends StatelessWidget {
  final String uid;
  final bool isDark;
  final AcceptRequestUseCase accept;
  final RejectRequestUseCase reject;
  final Color mutedColor;
  const _PendingCard({required this.uid, required this.isDark, required this.accept,
      required this.reject, required this.mutedColor});

  @override
  Widget build(BuildContext context) {
    return _Card(
      isDark: isDark,
      title: 'Pending Requests',
      icon: Icons.pending_actions_rounded,
      trailing: TextButton(
        onPressed: () => context.goNamed('faculty-requests'),
        child: Text('View all', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary)),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointment_requests')
            .where('faculty_id', isEqualTo: uid)
            .where('status', isEqualTo: 'pending')
            .limit(5)
            .snapshots(),
        builder: (context, ps) {
          if (ps.hasError) {
            return Center(child: Text('Failed to load.',
              style: GoogleFonts.inter(fontSize: 13, color: mutedColor)));
          }
          if (!ps.hasData) {
            return Column(
              children: List.generate(
                3,
                (index) => const SkeletonRequestTile(),
              ),
            );
          }
          final docs = ps.data!.docs.toList()
            ..sort((a, b) {
              final at = (a['created_at'] as dynamic)?.seconds ?? 0;
              final bt = (b['created_at'] as dynamic)?.seconds ?? 0;
              return (bt as int).compareTo(at as int);
            });
          if (docs.isEmpty) {
            return Padding(padding: const EdgeInsets.all(16),
              child: Center(child: Text('No pending requests',
                  style: GoogleFonts.inter(fontSize: 13, color: mutedColor))));
          }
          return Column(children: docs.map((doc) {
            final d = EncryptionService.decryptFields(doc.data() as Map<String, dynamic>);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RequestTile(
                studentName: d['student_name'] as String? ?? 'Student',
                dateTime: '${d['date'] ?? ''} · ${d['time'] ?? ''}',
                purpose: d['purpose'] as String? ?? '',
                onAccept: () async {
                  await accept.call(requestId: doc.id, studentId: d['student_id'] as String? ?? '');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Accepted')));
                  }
                },
                onReject: () async {
                  await reject.call(requestId: doc.id, studentId: d['student_id'] as String? ?? '');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Rejected')));
                  }
                },
                onView: () => DialogHelper.showViewRequestModal(context,
                  studentName: d['student_name'] as String? ?? '',
                  date: d['date'] as String? ?? '',
                  time: d['time'] as String? ?? '',
                  purpose: d['purpose'] as String? ?? '',
                  onAccept: () async => accept.call(requestId: doc.id, studentId: d['student_id'] as String? ?? ''),
                  onReject: () async => reject.call(requestId: doc.id, studentId: d['student_id'] as String? ?? ''),
                ),
              ),
            );
          }).toList());
        },
      ),
    );
  }
}

// ── Overview pie chart card ────────────────────────────────────────────────
class _OverviewCard extends StatelessWidget {
  final int pending, approved, rejected, completed, cancelled;
  final bool isDark;
  const _OverviewCard({required this.pending, required this.approved, required this.rejected,
      required this.completed, required this.cancelled, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _Card(
      isDark: isDark,
      title: 'Overview',
      icon: Icons.pie_chart_outline_rounded,
      child: AppointmentPieChart(
        pending: pending, approved: approved, rejected: rejected,
        completed: completed, cancelled: cancelled,
      ),
    );
  }
}

// ── Quick actions card ─────────────────────────────────────────────────────
class _QuickActionsCard extends StatelessWidget {
  final bool isDark;
  const _QuickActionsCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QA('Manage Availability', Icons.schedule_rounded,   AppColors.primary,        'faculty-availability'),
      _QA('All Requests',        Icons.inbox_rounded,       AppColors.statusPending,  'faculty-requests'),
      _QA('My Profile',          Icons.person_outline_rounded, AppColors.info,        'faculty-profile'),
    ];
    return _Card(
      isDark: isDark,
      title: 'Quick Actions',
      icon: Icons.bolt_rounded,
      child: Column(children: actions.map((a) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _QABtn(qa: a, isDark: isDark),
      )).toList()),
    );
  }
}

class _QA { final String label; final IconData icon; final Color color; final String route;
  const _QA(this.label, this.icon, this.color, this.route); }

class _QABtn extends StatelessWidget {
  final _QA qa; final bool isDark;
  const _QABtn({required this.qa, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.goNamed(qa.route),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: qa.color.withValues(alpha: isDark ? 0.12 : 0.07),
          border: Border.all(color: qa.color.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          Icon(qa.icon, size: 16, color: qa.color),
          const SizedBox(width: 10),
          Expanded(child: Text(qa.label,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: qa.color))),
          Icon(Icons.arrow_forward_ios_rounded, size: 11, color: qa.color.withValues(alpha: 0.5)),
        ]),
      ),
    );
  }
}

// ── Shared card container ──────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final bool isDark;
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;
  const _Card({required this.isDark, required this.title, required this.icon,
      required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkCard : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 15, color: mutedColor),
          const SizedBox(width: 7),
          Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
          const Spacer(),
          ?trailing,
        ]),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }
}

String _greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}
