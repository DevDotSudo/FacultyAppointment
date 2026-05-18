import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';

class NotificationDialog {
  static Future<void> showNotifications(BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  Icon(Icons.notifications_outlined, size: 20, color: textColor),
                  const SizedBox(width: 10),
                  Text('Notifications',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
                  const Spacer(),
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
                    .orderBy('created_at', descending: true)
                    .limit(30)
                    .snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snap.data!.docs;
                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_none_rounded, size: 48, color: mutedColor),
                          const SizedBox(height: 12),
                          Text('No notifications', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: textColor)),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: borderColor),
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
                        default: icon = Icons.notifications_rounded; iconColor = AppColors.primary;
                      }

                      return InkWell(
                        onTap: () {
                          FirebaseFirestore.instance.collection('notifications').doc(docs[i].id).update({'read': true});
                          _showDetail(context, title, message, icon, iconColor);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          color: isRead ? null : AppColors.primary.withValues(alpha: 0.04),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
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
                                          style: GoogleFonts.inter(fontSize: 14,
                                            fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
                                            color: textColor))),
                                        if (!isRead)
                                          Container(width: 8, height: 8,
                                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(message, maxLines: 2, overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(fontSize: 12, color: mutedColor)),
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

  static void _showDetail(BuildContext ctx, String title, String message, IconData icon, Color iconColor) {
    showDialog(
      context: ctx,
      builder: (c) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(ctx).brightness == Brightness.dark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 40, color: iconColor),
            const SizedBox(height: 16),
            Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            const SizedBox(height: 8),
            Text(message, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textBody), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.of(c).pop(), child: const Text('OK'))),
          ]),
        ),
      ),
    );
  }
}