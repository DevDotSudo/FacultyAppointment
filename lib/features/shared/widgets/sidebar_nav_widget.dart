import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class SidebarNavItem {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final int? badge;

  SidebarNavItem({
    required this.label,
    required this.icon,
    this.isActive = false,
    required this.onTap,
    this.badge,
  });
}

class SidebarNavWidget extends StatelessWidget {
  final List<SidebarNavItem> items;
  final String appTitle;
  final VoidCallback onLogout;
  final bool collapsed;
  final VoidCallback onToggle;

  const SidebarNavWidget({
    super.key,
    required this.items,
    this.appTitle = '',
    required this.onLogout,
    this.collapsed = false,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F0F17) : const Color(0xFF1A1B2E);

    return Container(
      color: bg,
      child: Column(
        children: [
          // Header
          Container(
            height: 64,
            padding: EdgeInsets.symmetric(horizontal: collapsed ? 12 : 20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
            ),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 18),
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('AppointEase',
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis),
                  ),
                ],
                const Spacer(),
                InkWell(
                  onTap: onToggle,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(collapsed ? Icons.chevron_right : Icons.chevron_left,
                        color: Colors.white38, size: 18),
                  ),
                ),
              ],
            ),
          ),

          // Nav items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: collapsed ? 8 : 12, vertical: 12),
              children: items.map((item) => _NavItem(item: item, collapsed: collapsed)).toList(),
            ),
          ),

          // Logout
          Container(
            padding: EdgeInsets.symmetric(horizontal: collapsed ? 8 : 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
            ),
            child: _NavItem(
              item: SidebarNavItem(label: 'Logout', icon: Icons.logout_rounded, onTap: onLogout),
              collapsed: collapsed,
              isLogout: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final SidebarNavItem item;
  final bool collapsed;
  final bool isLogout;

  const _NavItem({required this.item, required this.collapsed, this.isLogout = false});

  @override
  Widget build(BuildContext context) {
    final active = item.isActive;
    final iconColor = isLogout
        ? AppColors.danger
        : active
            ? Colors.white
            : Colors.white38;
    final labelColor = isLogout ? Colors.white38 : active ? Colors.white : Colors.white54;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Tooltip(
        message: collapsed ? item.label : '',
        preferBelow: false,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(horizontal: collapsed ? 10 : 12, vertical: 10),
            decoration: BoxDecoration(
              color: active ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: active ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1) : null,
            ),
            child: Row(
              mainAxisSize: collapsed ? MainAxisSize.min : MainAxisSize.max,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(item.icon, size: 18, color: iconColor),
                    if ((item.badge ?? 0) > 0)
                      Positioned(
                        right: -6, top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                          constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                          child: Text('${item.badge}',
                            style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                        ),
                      ),
                  ],
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(item.label,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        color: labelColor,
                      ),
                      overflow: TextOverflow.ellipsis),
                  ),
                  if (active)
                    Container(width: 4, height: 4,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
