import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class SidebarNavItem {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  SidebarNavItem({
    required this.label,
    required this.icon,
    this.isActive = false,
    required this.onTap,
  });
}

class SidebarNavWidget extends StatelessWidget {
  final List<SidebarNavItem> items;
  final String appTitle;
  final VoidCallback onLogout;

  const SidebarNavWidget({
    super.key,
    required this.items,
    this.appTitle = 'Appointment System',
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Responsive sidebar width: 260 on wide screens, 220 on smaller, no less than 200
    final sidebarWidth = screenWidth > 1200 ? 260.0 : (screenWidth > 768 ? 240.0 : 200.0);
    final iconSize = screenWidth > 768 ? 24.0 : 20.0;
    final titleSize = screenWidth > 768 ? 15.0 : 13.0;
    final navFontSize = screenWidth > 768 ? 15.0 : 14.0;
    final navPadding = screenWidth > 768 ? 14.0 : 12.0;

    return Container(
      width: sidebarWidth,
      color: AppColors.darkNavy,
      child: Column(
        children: [
          // Top section: icon + title
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.calendar_month, color: AppColors.white, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    appTitle,
                    style: GoogleFonts.inter(
                      color: AppColors.white,
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Separator
          Container(height: 1, color: AppColors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 12),
          // Nav items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildNavItem(item, iconSize, navFontSize, navPadding);
              },
            ),
          ),
          // Logout item at bottom
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: _buildNavItem(
              SidebarNavItem(
                label: 'Logout',
                icon: Icons.logout,
                isActive: false,
                onTap: onLogout,
              ),
              iconSize,
              navFontSize,
              navPadding,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNavItem(SidebarNavItem item, double iconSize, double fontSize, double vPadding) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: 16),
        decoration: BoxDecoration(
          color: item.isActive ? AppColors.activeNavBg : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(item.icon, size: iconSize, color: AppColors.white),
            const SizedBox(width: 12),
            Text(
              item.label,
              style: GoogleFonts.inter(
                color: AppColors.white,
                fontSize: fontSize,
                fontWeight: item.isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}