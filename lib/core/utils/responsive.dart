import 'package:flutter/material.dart';

/// Complete responsive layout system for Faculty Appointment app.
/// All breakpoint decisions use MediaQuery.of(context).size.width.
class Responsive {
  const Responsive._();

  // ══════════════════════════════════════════════
  // BREAKPOINTS
  // ══════════════════════════════════════════════
  static const double mobileS = 320;
  static const double mobileM = 375;
  static const double mobileL = 425; // 425–767
  static const double tablet = 768;  // 768–1023
  static const double desktopS = 1024; // 1024–1439
  static const double desktopL = 1440; // 1440+

  // ── Device detection ──
  static bool isMobileS(double w) => w < mobileM;
  static bool isMobileM(double w) => w >= mobileM && w < mobileL;
  static bool isMobileL(double w) => w >= mobileL && w < tablet;
  static bool isMobile(double w) => w < tablet;
  static bool isTablet(double w) => w >= tablet && w < desktopS;
  static bool isDesktopS(double w) => w >= desktopS && w < desktopL;
  static bool isDesktopL(double w) => w >= desktopL;
  static bool isDesktop(double w) => w >= desktopS;

  // Convenience
  static double widthOf(BuildContext context) => MediaQuery.of(context).size.width;

  // ══════════════════════════════════════════════
  // NAVIGATION PATTERN
  // ══════════════════════════════════════════════
  static bool showBottomNav(double w) => w < tablet;              // Mobile: BottomNavigationBar
  static bool showDrawer(double w) => w >= tablet && w < desktopS; // Tablet: Drawer
  static bool showSidebar(double w) => w >= desktopS;              // Desktop: permanent sidebar

  static double sidebarWidth(double w) {
    if (w >= desktopL) return 280;
    if (w >= desktopS) return 260;
    if (w >= tablet) return 240;
    return 0;
  }

  // ══════════════════════════════════════════════
  // SPACING TOKENS
  // ══════════════════════════════════════════════
  static EdgeInsets outerPadding(double w) {
    if (w < mobileM) return const EdgeInsets.all(12);
    if (w < mobileL) return const EdgeInsets.all(20);
    if (w < tablet) return const EdgeInsets.all(24);
    if (w < desktopS) return const EdgeInsets.all(32);
    return const EdgeInsets.all(48);
  }

  static double gutter(double w) {
    if (w < mobileM) return 12;
    if (w < mobileL) return 16;
    if (w < tablet) return 20;
    if (w < desktopS) return 24;
    return 28;
  }

  static double sectionGap(double w) {
    if (w < mobileM) return 24;
    if (w < mobileL) return 32;
    if (w < tablet) return 40;
    if (w < desktopS) return 48;
    return 56;
  }

  static EdgeInsets cardPadding(double w) {
    if (w < mobileM) return const EdgeInsets.all(12);
    if (w < mobileL) return const EdgeInsets.all(16);
    if (w < tablet) return const EdgeInsets.all(20);
    if (w < desktopS) return const EdgeInsets.all(24);
    return const EdgeInsets.all(28);
  }

  static double headerHeight(double w) {
    if (w < mobileM) return 48;
    if (w < mobileL) return 52;
    if (w < tablet) return 56;
    if (w < desktopS) return 60;
    return 64;
  }

  // ══════════════════════════════════════════════
  // TYPOGRAPHY SCALE
  // Minimum font size is 11px anywhere.
  // ══════════════════════════════════════════════
  static TextStyle display1(double w) => TextStyle(
    fontSize: w < mobileL ? 24 : w < tablet ? 28 : w < desktopS ? 32 : w < desktopL ? 36 : 40,
    fontWeight: FontWeight.w700,
  );

  static TextStyle h2(double w) => TextStyle(
    fontSize: w < mobileL ? 20 : w < tablet ? 22 : w < desktopS ? 24 : w < desktopL ? 26 : 28,
    fontWeight: FontWeight.w600,
  );

  static TextStyle h3(double w) => TextStyle(
    fontSize: w < mobileL ? 17 : w < tablet ? 18 : w < desktopS ? 19 : w < desktopL ? 20 : 22,
    fontWeight: FontWeight.w600,
  );

  static TextStyle h4(double w) => TextStyle(
    fontSize: w < mobileL ? 15 : w < tablet ? 16 : w < desktopS ? 16 : w < desktopL ? 17 : 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle body(double w) {
    final double fontSize;
    final double height;
    if (w < mobileM) { fontSize = 14; height = 1.6; }
    else if (w < mobileL) { fontSize = 15; height = 1.65; }
    else if (w < tablet) { fontSize = 15; height = 1.7; }
    else { fontSize = 16; height = 1.7; }
    return TextStyle(fontSize: fontSize, fontWeight: FontWeight.w400, height: height);
  }

  static TextStyle small(double w) {
    if (w < mobileM) return const TextStyle(fontSize: 12);
    if (w < mobileL) return const TextStyle(fontSize: 13);
    if (w < desktopS) return const TextStyle(fontSize: 13);
    return const TextStyle(fontSize: 14);
  }

  static TextStyle label(double w) {
    if (w < desktopS) return const TextStyle(fontSize: 11, fontWeight: FontWeight.w500);
    return const TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
  }

  static TextStyle button(double w) {
    if (w < mobileL) return const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
    if (w < tablet) return const TextStyle(fontSize: 15, fontWeight: FontWeight.w500);
    if (w < desktopS) return const TextStyle(fontSize: 15, fontWeight: FontWeight.w500);
    return const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  }

  static TextStyle navItem(double w) {
    if (w < tablet) return const TextStyle(fontSize: 13, fontWeight: FontWeight.w500);
    return const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  }

  static TextStyle code(double w) {
    if (w < mobileL) return const TextStyle(fontSize: 12);
    if (w < tablet) return const TextStyle(fontSize: 13);
    if (w < desktopL) return const TextStyle(fontSize: 14);
    return const TextStyle(fontSize: 14);
  }

  // ══════════════════════════════════════════════
  // COMPONENT SIZES
  // ══════════════════════════════════════════════
  static double inputHeight(double w) {
    if (w < desktopS) return 44;
    return 40;
  }

  static double buttonHeight(double w) {
    if (w < desktopS) return 44;
    return 40;
  }

  static double touchTarget(double w) {
    if (w < desktopS) return 44;
    return 36;
  }

  static double cardRadius(double w) {
    if (w < mobileL) return 10;
    if (w < tablet) return 12;
    if (w < desktopS) return 12;
    return 14;
  }

  static double inputRadius(double w) => 8;

  // ══════════════════════════════════════════════
  // LAYOUT
  // ══════════════════════════════════════════════
  /// Desktop L content must be centered with max-width: 1440
  static Widget maxWidthContainer(double screenWidth, Widget child) {
    if (screenWidth >= desktopL) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: desktopL),
          child: child,
        ),
      );
    }
    return child;
  }

  /// Stat cards: Mobile S/M = 2×2 grid; Mobile L+ = 4-column row
  static bool statCardsTwoCol(double w) => w < mobileL;

  /// Two-column layout unlocks when content area ≥ 600px
  static bool isTwoCol(double contentWidth) => contentWidth >= 600;

  /// Max readable text column width: 72–80 characters (~600px)
  static double maxTextWidth(double w) => w >= desktopS ? 600 : double.infinity;

  // ══════════════════════════════════════════════
  // Shared spacing scale utilities
  // ══════════════════════════════════════════════
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;
  static const double s56 = 56;

  // ══════════════════════════════════════════════
  // BACKWARD-COMPATIBLE HELPERS
  // ══════════════════════════════════════════════
  static EdgeInsets pagePadding(BuildContext context) => outerPadding(widthOf(context));
  static bool isMobileContext(BuildContext context) => isMobile(widthOf(context));
  static bool isDesktopContext(BuildContext context) => isDesktop(widthOf(context));
  static bool showSidebarFromWidth(double w) => w >= desktopS;
  static double maxContentWidth(double w) => w >= desktopL ? desktopL : double.infinity;
  static double maxContentWidthCtx(BuildContext context) => maxContentWidth(widthOf(context));
  static bool isTwoColCtx(double contentWidth) => contentWidth >= 600;
}