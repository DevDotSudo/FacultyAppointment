import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import 'skeleton_loader.dart';
import 'notification_service.dart';

class NotificationDialog {
  static Future<void> showNotifications(BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final w = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(Responsive.cardRadius(w))),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.gutter(w),
                vertical: Responsive.s16,
              ),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  Icon(Icons.notifications_outlined, size: 20, color: textColor),
                  const SizedBox(width: 10),
                  Text('Notifications',
                    style: GoogleFonts.inter(
                      fontSize: Responsive.body(w).fontSize,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
                  const Spacer(),
                  // Mark all as read button
                  TextButton(
                    onPressed: () async {
                      await NotificationService().markAllAsRead(userId);
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text('All notifications marked as read'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text('Mark all read',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: Icon(Icons.close_rounded, size: 20, color: mutedColor),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notifications')
                    .where('user_id', isEqualTo: userId)
                    .limit(30)
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Center(child: Text('Failed to load notifications.',
                        style: GoogleFonts.inter(fontSize: 13, color: mutedColor)));
                  }
                  if (!snap.hasData) {
                    return Column(
                      children: List.generate(
                        3,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              SkeletonLoader.circle(size: 40),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SkeletonLoader.rectangle(
                                      width: 200,
                                      height: 14,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    const SizedBox(height: 6),
                                    SkeletonLoader.rectangle(
                                      width: 120,
                                      height: 12,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  final docs = snap.data!.docs.toList()
                    ..sort((a, b) {
                      final at = (a['created_at'] as dynamic)?.seconds ?? 0;
                      final bt = (b['created_at'] as dynamic)?.seconds ?? 0;
                      return (bt as int).compareTo(at as int);
                    });
                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_none_rounded, size: 48, color: mutedColor),
                          const SizedBox(height: 12),
                          Text('No notifications',
                            style: GoogleFonts.inter(
                              fontSize: Responsive.body(w).fontSize,
                              fontWeight: FontWeight.w500,
                              color: textColor)),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, _) => Divider(height: 1, color: borderColor),
                    itemBuilder: (_, i) {
                      final d = docs[i].data() as Map<String, dynamic>;
                      final title = d['title'] as String? ?? '';
                      final message = d['message'] as String? ?? '';
                      final isRead = d['read'] as bool? ?? false;
                      final type = d['type'] as String? ?? '';

                      IconData icon;
                      Color iconColor;
                      switch (type) {
                        case 'request': icon = Icons.calendar_month_rounded; iconColor = AppColors.statusPending; break;
                        case 'accept': icon = Icons.check_circle_outline_rounded; iconColor = AppColors.statusAccepted; break;
                        case 'reject': icon = Icons.cancel_outlined; iconColor = AppColors.statusRejected; break;
                        case 'cancel': icon = Icons.event_busy_rounded; iconColor = mutedColor; break;
                        case 'reschedule': icon = Icons.event_repeat_rounded; iconColor = AppColors.primary; break;
                        case 'complete': icon = Icons.task_alt_rounded; iconColor = const Color(0xFF6366F1); break;
                        default: icon = Icons.notifications_rounded; iconColor = AppColors.primary;
                      }

                      return InkWell(
                        onTap: () {
                          FirebaseFirestore.instance.collection('notifications').doc(docs[i].id).update({'read': true});
                          _showDetail(context, w, title, message, icon, iconColor);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.gutter(w),
                            vertical: Responsive.s12,
                          ),
                          color: isRead ? null : AppColors.primary.withValues(alpha: 0.04),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(Responsive.s8),
                                decoration: BoxDecoration(
                                  color: iconColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(icon, size: 18, color: iconColor),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: Text(title,
                                          style: GoogleFonts.inter(
                                            fontSize: (Responsive.body(w).fontSize ?? 14) - 1,
                                            fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
                                            color: textColor))),
                                        if (!isRead)
                                          Container(width: 8, height: 8,
                                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(message, maxLines: 2, overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: Responsive.small(w).fontSize,
                                        color: mutedColor)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showDetail(BuildContext ctx, double w, String title, String message, IconData icon, Color iconColor) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final bodyColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final bgColor = isDark ? AppColors.darkSurface : Colors.white;

    showDialog(
      context: ctx,
      builder: (c) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 40, color: iconColor),
              const SizedBox(height: 16),
              Text(title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor),
                textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(message,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: bodyColor),
                textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(c).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('OK'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}