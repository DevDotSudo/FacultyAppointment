import 'package:flutter/material.dart';

class Responsive {
  // ── Breakpoints ──────────────────────────────────────────────────────────
  static const double mobileS = 320;
  static const double mobileM = 375;
  static const double mobileL = 425;
  static const double tablet = 768;
  static const double laptop = 1024;
  static const double desktop = 1440;

  // ── Device category checks ───────────────────────────────────────────────

  static bool isMobileS(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w < mobileM;
  }

  static bool isMobileM(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= mobileM && w < mobileL;
  }

  static bool isMobileL(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= mobileL && w < tablet;
  }

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < tablet;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= tablet && w < laptop;
  }

  static bool isDesktopS(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= laptop && w < desktop;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= laptop;

  static bool isDesktopL(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;

  // ── Sidebar / layout mode ────────────────────────────────────────────────

  /// Mobile & tablet → sidebar as drawer
  static bool showSidebarDrawer(BuildContext context) =>
      MediaQuery.of(context).size.width < laptop;

  /// Desktop S & L → persistent sidebar visible
  static bool showSidebar(BuildContext context) =>
      MediaQuery.of(context).size.width >= laptop;

  // ── Sidebar widths ───────────────────────────────────────────────────────

  static double sidebarWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= desktop) return 280;       // Desktop L
    if (w >= laptop) return 260;        // Desktop S
    return 240;                          // Tablet drawer
  }

  // ── Content width constraints ────────────────────────────────────────────

  /// Max content width: 1440 for desktop L, else unconstrained
  static double maxContentWidth(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop ? 1440 : double.infinity;

  // ── Two-column layout threshold inside content area ──────────────────────

  static bool isTwoCol(double contentWidth) => contentWidth >= 600;

  // ── Stat card grid: 2-col vs 4-col ───────────────────────────────────────

  /// Stat cards should use 2×2 grid when content width < 600
  static bool statCardsTwoCol(double contentWidth) => contentWidth < 600;

  // ── Responsive padding ───────────────────────────────────────────────────

  static EdgeInsets pagePadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < mobileM) return const EdgeInsets.all(12);        // Mobile S: 12px
    if (w < mobileL) return const EdgeInsets.all(20);        // Mobile L: 20px
    if (w < tablet) return const EdgeInsets.all(20);         // Mobile L upper: 20px
    if (w < laptop) return const EdgeInsets.all(24);         // Tablet: 24px
    if (w < desktop) return const EdgeInsets.all(32);        // Desktop S: 32px
    return const EdgeInsets.all(48);                         // Desktop L: 48px
  }

  // ── Font scale helper ────────────────────────────────────────────────────

  static double fontSize(BuildContext context, double base) {
    final w = MediaQuery.of(context).size.width;
    if (w < mobileL) return base - 2;
    if (w < tablet) return base - 1;
    return base;
  }
}
