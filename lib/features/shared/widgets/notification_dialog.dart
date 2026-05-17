import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import 'custom_dialog.dart';

class NotificationDialog {
  /// Shows notifications panel for the current user
  static Future<void> showNotifications(BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.textDark;

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 500),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBg : AppColors.primaryBg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.notifications_rounded, color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                    Text('Notifications',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                    const Spacer(),
                    InkWell(
                      onTap: () => Navigator.of(ctx).pop(),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
              // List
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notifications')
                    .where('user_id', isEqualTo: userId)
                    .orderBy('created_at', descending: true)
                    .limit(20)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.notifications_none_rounded, size: 48, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            Text('No notifications yet',
                              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: textColor)),
                          ],
                        ),
                      ),
                    );
                  }
                  return Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: docs.length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.borderGray),
                      itemBuilder: (context, index) {
                        final d = docs[index].data() as Map<String, dynamic>;
                        final type = d['type'] as String? ?? '';
                        final title = d['title'] as String? ?? '';
                        final message = d['message'] as String? ?? '';
                        final isRead = d['read'] as bool? ?? false;

                        // Icon based on type
                        IconData icon;
                        Color iconColor;
                        switch (type) {
                          case 'request':
                            icon = Icons.calendar_month_rounded;
                            iconColor = AppColors.warning;
                            break;
                          case 'accept':
                            icon = Icons.check_circle_outline_rounded;
                            iconColor = AppColors.success;
                            break;
                          case 'reject':
                            icon = Icons.cancel_outlined;
                            iconColor = AppColors.danger;
                            break;
                          case 'cancel':
                            icon = Icons.event_busy_rounded;
                            iconColor = AppColors.textMuted;
                            break;
                          default:
                            icon = Icons.notifications_rounded;
                            iconColor = AppColors.primary;
                        }

                        return InkWell(
                          onTap: () async {
                            // Mark as read and show details
                            await FirebaseFirestore.instance
                                .collection('notifications')
                                .doc(docs[index].id)
                                .update({'read': true});
                            if (context.mounted) {
                              _showNotificationDetail(context, title, message, icon, iconColor);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            color: isRead ? Colors.transparent : AppColors.primary.withValues(alpha: 0.05),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: iconColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(icon, size: 18, color: iconColor),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(title,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
                                          color: textColor,
                                        )),
                                      const SizedBox(height: 2),
                                      Text(message,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: AppColors.textMuted,
                                        )),
                                    ],
                                  ),
                                ),
                                if (!isRead)
                                  Container(
                                    width: 8, height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary, shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _showNotificationDetail(
    BuildContext context,
    String title,
    String message,
    IconData icon,
    Color iconColor,
  ) {
    return showDialog(
      context: context,
      builder: (ctx) => CustomDialog(
        title: title,
        actions: [
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          )),
        ],
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 36, color: iconColor),
          ),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
            textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}