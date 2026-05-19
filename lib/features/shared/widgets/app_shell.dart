import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/utils/responsive.dart';
import 'dialog_helper.dart';
import 'notification_dialog.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _unread = 0;
  StreamSubscription? _sub;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _sub = FirebaseFirestore.instance
          .collection('notifications')
          .where('user_id', isEqualTo: uid)
          .where('read', isEqualTo: false)
          .snapshots()
          .listen((s) { if (mounted) setState(() => _unread = s.docs.length); });
    }
  }

  @override
  void dispose() { _sub?.cancel(); super.dispose(); }

  List<_NavItem> _navItems(String uri) {
    if (uri.startsWith('/student')) {
      return [
        _NavItem(Icons.grid_view_rounded,      'Dashboard',    '/student/dashboard',        'student-dashboard'),
        _NavItem(Icons.school_rounded,          'Faculty',      '/student/faculty',          'student-faculty'),
        _NavItem(Icons.calendar_month_rounded,  'Appointments', '/student/my-appointments',  'student-my-appointments'),
        _NavItem(Icons.person_rounded,          'Profile',      '/student/profile',          'student-profile'),
      ];
    }
    return [
      _NavItem(Icons.dashboard_rounded,  'Dashboard',    '/faculty/dashboard',    'faculty-dashboard'),
      _NavItem(Icons.inbox_rounded,      'Requests',     '/faculty/requests',     'faculty-requests'),
      _NavItem(Icons.schedule_rounded,   'Availability', '/faculty/availability', 'faculty-availability'),
      _NavItem(Icons.person_rounded,     'Profile',      '/faculty/profile',      'faculty-profile'),
    ];
  }

  String _pageTitle(String uri, List<_NavItem> items) {
    for (final i in items) { if (i.path == uri) return i.label; }
    if (uri.contains('book-appointment')) return 'Book Appointment';
    if (uri.contains('appointment-detail')) return 'Appointment Details';
    if (uri.contains('request-detail')) return 'Request Details';
    return 'Dashboard';
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await DialogHelper.showConfirmDialog(context,
        title: 'Sign out', message: 'Are you sure you want to sign out?',
        confirmLabel: 'Sign out', confirmColor: AppColors.danger);
    if (ok == true && context.mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', false);
      await FirebaseAuth.instance.signOut().catchError((_) {});
      if (context.mounted) context.goNamed('login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final uri = GoRouterState.of(context).uri.toString();
    final items = _navItems(uri);
    final isMobile = Responsive.isMobile(w);
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg; // Slate 100 for light mode!
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    // Shared appbar actions
    List<Widget> appBarActions() => [
      _ThemeBtn(isDark: isDark),
      const SizedBox(width: 4),
      _NotifBtn(unread: _unread, isDark: isDark),
      const SizedBox(width: 8),
    ];

    if (isMobile) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: surfaceColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: borderColor),
          ),
          leading: IconButton(
            icon: Icon(Icons.menu_rounded, color: textColor, size: 22),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          title: Text(_pageTitle(uri, items),
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
          actions: appBarActions(),
        ),
        drawer: Drawer(
          backgroundColor: surfaceColor,
          width: 260,
          child: SafeArea(child: _Sidebar(items: items, uri: uri, isDark: isDark, onLogout: () {
            Navigator.of(context).pop();
            _logout(context);
          })),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: Responsive.outerPadding(w),
            child: widget.child,
          ),
        ),
      );
    }

    // Tablet / Desktop — persistent sidebar
    return Scaffold(
      backgroundColor: bgColor,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar
          SizedBox(
            width: Responsive.sidebarWidth(w),
            child: _Sidebar(items: items, uri: uri, isDark: isDark, onLogout: () => _logout(context)),
          ),
          // Main area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top bar
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    border: Border(bottom: BorderSide(color: borderColor)),
                  ),
                  child: Row(children: [
                    Text(_pageTitle(uri, items),
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
                    const Spacer(),
                    ...appBarActions(),
                  ]),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: Responsive.outerPadding(w),
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sidebar
// ─────────────────────────────────────────────────────────────────────────────
class _Sidebar extends StatelessWidget {
  final List<_NavItem> items;
  final String uri;
  final bool isDark;
  final VoidCallback onLogout;
  const _Sidebar({required this.items, required this.uri, required this.isDark, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkSidebarBg : AppColors.lightSidebarBg; // Dark sidebar!
    final border = isDark ? AppColors.darkBorder : const Color(0xFF334155); // Slate 700
    final textColor = Colors.white; // White text on dark sidebar
    final mutedColor = Colors.white70; // White 70% for inactive items

    return Container(
      color: bg,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Brand
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: border))),
          child: Row(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary, // Flat design - solid color
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text('AppointEase',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: textColor)),
          ]),
        ),
        // Nav
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            children: items.map((item) {
              final active = item.path == uri;
              return _SidebarTile(item: item, active: active, isDark: isDark,
                  textColor: textColor, mutedColor: mutedColor);
            }).toList(),
          ),
        ),
        // Sign out
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: border))),
          child: InkWell(
            onTap: onLogout,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(children: [
                const Icon(Icons.logout_rounded, size: 18, color: AppColors.statusRejected),
                const SizedBox(width: 12),
                Text('Sign out',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.statusRejected)),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final _NavItem item;
  final bool active;
  final bool isDark;
  final Color textColor;
  final Color mutedColor;
  const _SidebarTile({required this.item, required this.active, required this.isDark,
      required this.textColor, required this.mutedColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary.withValues(alpha: 0.2) // Brighter active state
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          if (Responsive.isMobile(MediaQuery.of(context).size.width)) {
            Navigator.of(context).pop();
          }
          context.goNamed(item.routeName);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(children: [
            Icon(item.icon, size: 18, color: active ? Colors.white : mutedColor),
            const SizedBox(width: 12),
            Expanded(child: Text(item.label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: active ? Colors.white : textColor,
                ))),
            if (active)
              Container(width: 6, height: 6,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppBar action buttons
// ─────────────────────────────────────────────────────────────────────────────
class _ThemeBtn extends StatelessWidget {
  final bool isDark;
  const _ThemeBtn({required this.isDark});
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          size: 20, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
      tooltip: isDark ? 'Light mode' : 'Dark mode',
      onPressed: () => context.read<ThemeCubit>().toggleTheme(),
    );
  }
}

class _NotifBtn extends StatelessWidget {
  final int unread;
  final bool isDark;
  const _NotifBtn({required this.unread, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, children: [
      IconButton(
        icon: Icon(Icons.notifications_outlined, size: 22,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
        onPressed: () => NotificationDialog.showNotifications(context),
      ),
      if (unread > 0)
        Positioned(right: 6, top: 6,
          child: Container(
            width: 16, height: 16,
            decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
            child: Center(child: Text('$unread',
                style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white))),
          )),
    ]);
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String path;
  final String routeName;
  const _NavItem(this.icon, this.label, this.path, this.routeName);
}
