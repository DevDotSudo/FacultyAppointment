import 'package:faculty_appointment/features/shared/widgets/dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import 'sidebar_nav_widget.dart';
import '../../../core/utils/responsive.dart';
import 'notification_dialog.dart';


class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _sidebarCollapsed = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<SidebarNavItem> _buildItems(BuildContext context) {
    final uri = GoRouterState.of(context).uri.toString();
    if (uri.startsWith('/student')) {
      return [
        SidebarNavItem(label: 'Dashboard', icon: Icons.grid_view_rounded,
          isActive: uri == '/student/dashboard',
          onTap: () { _closeDrawer(); context.goNamed('student-dashboard'); }),
        SidebarNavItem(label: 'Faculty', icon: Icons.school_rounded,
          isActive: uri == '/student/faculty',
          onTap: () { _closeDrawer(); context.goNamed('student-faculty'); }),
        SidebarNavItem(label: 'Appointments', icon: Icons.calendar_month_rounded,
          isActive: uri.contains('/student/my-appointments') || uri.contains('/student/book-appointment') || uri.contains('/student/appointment-detail'),
          onTap: () { _closeDrawer(); context.goNamed('student-my-appointments'); }),
        SidebarNavItem(label: 'Profile', icon: Icons.person_rounded,
          isActive: uri == '/student/profile',
          onTap: () { _closeDrawer(); context.goNamed('student-profile'); }),
      ];
    }
    return [
      SidebarNavItem(label: 'Dashboard', icon: Icons.grid_view_rounded,
        isActive: uri == '/faculty/dashboard',
        onTap: () { _closeDrawer(); context.goNamed('faculty-dashboard'); }),
      SidebarNavItem(label: 'Requests', icon: Icons.inbox_rounded,
        isActive: uri.contains('/faculty/requests') || uri.contains('/faculty/request-detail'),
        onTap: () { _closeDrawer(); context.goNamed('faculty-requests'); }),
      SidebarNavItem(label: 'Availability', icon: Icons.schedule_rounded,
        isActive: uri == '/faculty/availability',
        onTap: () { _closeDrawer(); context.goNamed('faculty-availability'); }),
      SidebarNavItem(label: 'Profile', icon: Icons.person_rounded,
        isActive: uri == '/faculty/profile',
        onTap: () { _closeDrawer(); context.goNamed('faculty-profile'); }),
    ];
  }

  void _closeDrawer() {
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      _scaffoldKey.currentState?.closeDrawer();
    }
  }

  void _confirmLogout(BuildContext context) {
    DialogHelper.showConfirmDialog(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmLabel: 'Sign Out',
      confirmColor: AppColors.danger,
    ).then((confirmed) {
      if (confirmed == true && context.mounted) context.goNamed('login');
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildItems(context);
    final isDesktop = Responsive.showSidebar(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : const Color(0xFFF4F5F7);

    Widget drawerContent = SafeArea(
      child: Column(children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Text('AppointEase', style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
          ]),
        ),
        const SizedBox(height: 20),
        Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: items.map((item) => _DrawerItem(item: item)).toList(),
          ),
        ),
        Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
        Padding(
          padding: const EdgeInsets.all(12),
          child: _DrawerItem(
            item: SidebarNavItem(label: 'Sign Out', icon: Icons.logout_rounded,
              onTap: () { _closeDrawer(); _confirmLogout(context); }),
            isLogout: true,
          ),
        ),
      ]),
    );

    final appBar = AppBar(
      backgroundColor: isDark ? const Color(0xFF0F0F17) : const Color(0xFF1A1B2E),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Text('AppointEase', style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
      ]),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 20, color: Colors.white70),
          onPressed: () => NotificationDialog.showNotifications(context),
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, size: 20, color: Colors.white54),
          onPressed: () => _confirmLogout(context),
        ),
      ],
    );

    if (!isDesktop) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: bg,
        appBar: appBar,
        drawer: Drawer(
          width: 260,
          backgroundColor: isDark ? const Color(0xFF0F0F17) : const Color(0xFF1A1B2E),
          child: drawerContent,
        ),
        body: SingleChildScrollView(
          padding: Responsive.pagePadding(context),
          child: widget.child,
        ),
      );
    }

    final maxW = Responsive.maxContentWidth(context);
    final sidebarW = Responsive.sidebarWidth(context);

    return Scaffold(
      backgroundColor: bg,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            width: _sidebarCollapsed ? 60 : sidebarW,
            child: SidebarNavWidget(
              items: items,
              collapsed: _sidebarCollapsed,
              onToggle: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
              onLogout: () => _confirmLogout(context),
            ),
          ),
          Expanded(
            child: Container(
              color: bg,
              child: SingleChildScrollView(
                padding: Responsive.pagePadding(context),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxW),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final SidebarNavItem item;
  final bool isLogout;
  const _DrawerItem({required this.item, this.isLogout = false});

  @override
  Widget build(BuildContext context) {
    final active = item.isActive;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            Icon(item.icon, size: 18,
              color: isLogout ? AppColors.danger : active ? Colors.white : Colors.white38),
            const SizedBox(width: 10),
            Text(item.label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: isLogout ? Colors.white38 : active ? Colors.white : Colors.white54,
              )),
          ]),
        ),
      ),
    );
  }
}
