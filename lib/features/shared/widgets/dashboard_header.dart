import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_cubit.dart';

class DashboardHeader extends StatelessWidget {
  final String name;
  final String role;
  final String initials;
  final String? searchHint;
  final void Function(String)? onSearch;

  const DashboardHeader({
    super.key,
    required this.name,
    required this.role,
    this.initials = '?',
    this.searchHint,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Good ${_greeting()}, $name 👋',
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(role,
                    style: GoogleFonts.inter(fontSize: 13,
                      color: isDark ? AppColors.darkMuted : AppColors.textMuted)),
                ],
              ),
            ),
            // Notification bell
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('user_id', isEqualTo: uid)
                  .where('read', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                final unread = snapshot.hasData ? snapshot.data!.docs.length : 0;
                return Stack(clipBehavior: Clip.none, children: [
                  _HeaderIconBtn(
                    icon: Icons.notifications_outlined,
                    isDark: isDark,
                    onTap: () => _showNotifications(context, uid, isDark),
                  ),
                  if (unread > 0)
                    Positioned(
                      right: 4, top: 4,
                      child: Container(
                        width: 16, height: 16,
                        decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                        child: Center(
                          child: Text('$unread',
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                ]);
              },
            ),
            const SizedBox(width: 4),
            // Theme toggle
            _HeaderIconBtn(
              icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              isDark: isDark,
              onTap: () => context.read<ThemeCubit>().toggleTheme(),
            ),
            const SizedBox(width: 8),
            // Avatar
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  initials.length >= 2 ? initials.substring(0, 2) : initials,
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
        if (searchHint != null && onSearch != null) ...[
          const SizedBox(height: 16),
          TextField(
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: searchHint,
              prefixIcon: Icon(Icons.search_rounded, size: 18,
                color: isDark ? AppColors.darkMuted : AppColors.textMuted),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              filled: true,
              fillColor: isDark ? AppColors.darkCard : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFEEEFF2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFEEEFF2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }

  void _showNotifications(BuildContext context, String uid, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(children: [
          const SizedBox(height: 12),
          Container(width: 36, height: 4,
            decoration: BoxDecoration(color: isDark ? AppColors.darkBorder : const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Text('Notifications', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.textDark)),
              const Spacer(),
              TextButton(
                onPressed: () => _markAllRead(uid),
                child: Text('Mark all read', style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary)),
              ),
            ]),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('user_id', isEqualTo: uid)
                  .orderBy('created_at', descending: true)
                  .limit(20)
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final notifs = snap.data!.docs;
                if (notifs.isEmpty) {
                  return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.notifications_none_rounded, size: 40,
                      color: isDark ? AppColors.darkMuted : AppColors.textMuted),
                    const SizedBox(height: 8),
                    Text('No notifications', style: GoogleFonts.inter(
                      color: isDark ? AppColors.darkMuted : AppColors.textMuted)),
                  ]));
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: notifs.length,
                  separatorBuilder: (context, index) => Divider(height: 1,
                    color: isDark ? AppColors.darkBorder : const Color(0xFFF0F1F3)),
                  itemBuilder: (context, i) {
                    final d = notifs[i].data() as Map<String, dynamic>;
                    final isRead = d['read'] as bool? ?? false;
                    final type = d['type'] as String? ?? '';
                    return ListTile(
                      leading: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: (type == 'accept' ? AppColors.success : type == 'reject' ? AppColors.danger : AppColors.primary).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          type == 'accept' ? Icons.check_circle_outline : type == 'reject' ? Icons.cancel_outlined : Icons.calendar_month_outlined,
                          size: 18,
                          color: type == 'accept' ? AppColors.success : type == 'reject' ? AppColors.danger : AppColors.primary,
                        ),
                      ),
                      title: Text(d['title'] as String? ?? '',
                        style: GoogleFonts.inter(fontSize: 13,
                          fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                          color: isDark ? AppColors.darkText : AppColors.textDark)),
                      subtitle: Text(d['message'] as String? ?? '',
                        style: GoogleFonts.inter(fontSize: 12,
                          color: isDark ? AppColors.darkMuted : AppColors.textMuted)),
                      trailing: isRead ? null : Container(width: 8, height: 8,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                      onTap: () => notifs[i].reference.update({'read': true}),
                    );
                  },
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _markAllRead(String uid) async {
    final snap = await FirebaseFirestore.instance
        .collection('notifications')
        .where('user_id', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }
}

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  const _HeaderIconBtn({required this.icon, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFEEEFF2)),
        ),
        child: Icon(icon, size: 18, color: isDark ? AppColors.darkMuted : AppColors.textMuted),
      ),
    );
  }
}
