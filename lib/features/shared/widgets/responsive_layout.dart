import 'package:flutter/material.dart';
import 'sidebar_nav_widget.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final List<SidebarNavItem> sidebarItems;
  final String appTitle;
  final VoidCallback onLogout;

  const ResponsiveLayout({
    super.key,
    required this.child,
    required this.sidebarItems,
    this.appTitle = 'Appointment System',
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SidebarNavWidget(
            items: sidebarItems,
            appTitle: appTitle,
            onLogout: onLogout,
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFF8FAFC),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}