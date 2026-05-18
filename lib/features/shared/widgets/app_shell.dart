import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  int _unreadCount = 0;
  StreamSubscription? _notifSub;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _notifSub = FirebaseFirestore.instance
          .collection('notifications')
          .where('user_id', isEqualTo: uid)
          .where('read', isEqualTo: false)
          .snapshots()
          .listen((snap) {
        if (mounted) setState(() => _unreadCount = snap.docs.length);
      });
    }
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    super.dispose();
  }

  List<_NavItem> _buildItems(BuildContext context) {
    final uri = GoRouterState.of(context).uri.toString();
    if (uri.startsWith('/student')) {
      return [
        _NavItem(Icons.grid_view_rounded, 'Dashboard', '/student/dashboard', 'student-dashboard'),
        _NavItem(Icons.school_rounded, 'Faculty', '/student/faculty', 'student-faculty'),
        _NavItem(Icons.calendar_month_rounded, 'Appointments', '/student/my-appointments', 'student-my-appointments'),
        _NavItem(Icons.person_rounded, 'Profile', '/student/profile', 'student-profile'),
      ];
    }
    return [
      _NavItem(Icons.dashboard_rounded, 'Dashboard', '/faculty/dashboard', 'faculty-dashboard'),
      _NavItem(Icons.inbox_rounded, 'Requests', '/faculty/requests', 'faculty-requests'),
      _NavItem(Icons.schedule_rounded, 'Availability', '/faculty/availability', 'faculty-availability'),
      _NavItem(Icons.person_rounded, 'Profile', '/faculty/profile', 'faculty-profile'),
    ];
  }

  void _confirmLogout(BuildContext context) {
    DialogHelper.showConfirmDialog(context,
      title: 'Sign out',
      message: 'Are you sure you want to sign out?',
      confirmLabel: 'Sign out',
      confirmColor: AppColors.danger,
    ).then((confirmed) {
      if (confirmed == true && context.mounted) context.goNamed('login');
    });
  }

  // ── Theme toggle icon button ──
  Widget _themeToggle(BuildContext context, bool isDark) {
    return IconButton(
      icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, size: 20),
      onPressed: () => context.read<ThemeCubit>().toggleTheme(),
      tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
    );
  }

  // ── Sidebar content (shared by Drawer and permanent sidebar) ──
  Widget _buildSidebar(BuildContext context, double screenWidth, List<_NavItem> navItems) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sidebarBg = isDark ? AppColors.darkSidebarBg : AppColors.lightSidebarBg;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final uri = GoRouterState.of(context).uri.toString();

    return Container(
      width: Responsive.showSidebar(screenWidth) ? Responsive.sidebarWidth(screenWidth) : null,
      decoration: BoxDecoration(
        color: sidebarBg,
        border: Responsive.showSidebar(screenWidth)
            ? Border(right: BorderSide(color: borderColor, width: 1))
            : null,
      ),
      child: Column(
        children: [
          // ── Brand header ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor))),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF8B5CF6)]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Text('AppointEase', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              ],
            ),
          ),
          // ── Nav items ──
          Expanded(
            child: ListView(padding: const EdgeInsets.symmetric(vertical: 8),
              children: navItems.map((item) => _navTile(item, uri, context, isDark, textColor, mutedColor)).toList()),
          ),
          // ── Bottom: Sign out only ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: borderColor))),
            child: InkWell(
              onTap: () {
                if (!Responsive.showSidebar(screenWidth)) Navigator.of(context).pop();
                _confirmLogout(context);
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 18,
                        color: isDark ? AppColors.darkDanger : AppColors.lightDanger),
                    const SizedBox(width: 12),
                    Text('Sign out', style: GoogleFonts.inter(fontSize: 14,
                        color: isDark ? AppColors.darkDanger : AppColors.lightDanger)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navTile(_NavItem item, String uri, BuildContext context, bool isDark, Color textColor, Color mutedColor) {
    final exactMatch = item.path == uri;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: exactMatch ? (isDark ? AppColors.darkNavActive.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.1)) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          if (!Responsive.showSidebar(Responsive.widthOf(context))) Navigator.of(context).pop();
          context.goNamed(item.routeName);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(item.icon, size: 18, color: exactMatch ? AppColors.primary : mutedColor),
              const SizedBox(width: 12),
              Text(item.label, style: GoogleFonts.inter(fontSize: 14,
                  fontWeight: exactMatch ? FontWeight.w600 : FontWeight.w400,
                  color: exactMatch ? AppColors.primary : textColor)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = Responsive.showSidebar(screenWidth);
    final uri = GoRouterState.of(context).uri.toString();
    final navItems = _buildItems(context);
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final headerBg = isDark ? AppColors.darkHeaderBg : AppColors.lightHeaderBg;

    // ══════════════════════════════════════════════
    // MOBILE & TABLET (320–1023px): AppBar + hamburger drawer (no bottom nav)
    // ══════════════════════════════════════════════
    if (!isDesktop) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: headerBg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          title: Text(_getPageTitle(uri, navItems),
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          actions: [
            _themeToggle(context, isDark),
            _notifBadge(context, isDark),
          ],
        ),
        drawer: Drawer(
          backgroundColor: isDark ? AppColors.darkSidebarBg : AppColors.lightSidebarBg,
          child: SafeArea(child: _buildSidebar(context, screenWidth, navItems)),
        ),
        body: SafeArea(
          child: Container(
            padding: Responsive.outerPadding(screenWidth),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: widget.child,
            ),
          ),
        ),
      );
    }

    // ══════════════════════════════════════════════
    // DESKTOP S (1024–1439px) + DESKTOP L (1440px+)
    // Permanent sidebar + top bar with content
    // ══════════════════════════════════════════════
    return Scaffold(
      backgroundColor: bgColor,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Permanent sidebar
          _buildSidebar(context, screenWidth, navItems),
          // Content area
          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth >= Responsive.desktopL ? 32 : 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    border: Border(bottom: BorderSide(color: borderColor)),
                  ),
                  child: Row(
                    children: [
                      Text(_getPageTitle(uri, navItems),
                          style: GoogleFonts.inter(
                            fontSize: screenWidth >= Responsive.desktopL ? 20 : 18,
                            fontWeight: FontWeight.w600,
                            color: textColor)),
                      const Spacer(),
                      _themeToggle(context, isDark),
                      const SizedBox(width: 8),
                      _notifBadgeDesktop(context, isDark, borderColor, mutedColor),
                    ],
                  ),
                ),
                // Scrollable content
                Expanded(
                  child: Responsive.maxWidthContainer(
                    screenWidth,
                    Container(
                      padding: Responsive.outerPadding(screenWidth),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Notification badge (mobile/tablet) ──
  Widget _notifBadge(BuildContext context, bool isDark) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white70),
          onPressed: () => NotificationDialog.showNotifications(context),
        ),
        if (_unreadCount > 0)
          Positioned(right: 8, top: 8,
            child: Container(
              width: 16, height: 16,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: Center(child: Text('$_unreadCount',
                  style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white))),
            ),
          ),
      ],
    );
  }

  // ── Notification badge (desktop) ──
  Widget _notifBadgeDesktop(BuildContext context, bool isDark, Color borderColor, Color textColor) {
    return InkWell(
      onTap: () => NotificationDialog.showNotifications(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Stack(
          children: [
            Icon(Icons.notifications_outlined, size: 20, color: textColor),
            if (_unreadCount > 0)
              Positioned(right: -2, top: -2,
                child: Container(
                  width: 16, height: 16,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: Center(child: Text('$_unreadCount',
                      style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white))),
                )),
          ],
        ),
      ),
    );
  }

  String _getPageTitle(String uri, List<_NavItem> items) {
    for (final item in items) {
      if (item.path == uri) return item.label;
    }
    if (uri.contains('book-appointment')) return 'Book Appointment';
    if (uri.contains('appointment-detail')) return 'Appointment Details';
    if (uri.contains('request-detail')) return 'Request Details';
    return 'Dashboard';
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String path;
  final String routeName;
  const _NavItem(this.icon, this.label, this.path, this.routeName);
}