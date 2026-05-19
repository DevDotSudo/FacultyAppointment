import 'package:flutter/material.dart';

/// Complete responsive layout system for Faculty Appointment app.
class Responsive {
  const Responsive._();

  // ══════════════════════════════════════════════
  // BREAKPOINTS
  // ══════════════════════════════════════════════
  static const double mobileS = 320;
  static const double mobileM = 375;
  static const double mobileL = 425;
  static const double tablet = 768;
  static const double desktopS = 1024;
  static const double desktopL = 1440;

  // ── Device detection ──
  static bool isMobile(double w) => w < tablet;
  static bool isTablet(double w) => w >= tablet && w < desktopS;
  static bool isDesktop(double w) => w >= desktopS;

  static double widthOf(BuildContext context) => MediaQuery.of(context).size.width;

  // ══════════════════════════════════════════════
  // NAVIGATION PATTERN
  // ══════════════════════════════════════════════
  static bool showBottomNav(double w) => w < tablet;
  static bool showDrawer(double w) => w >= tablet && w < desktopS;
  static bool showSidebar(double w) => w >= desktopS;

  static double sidebarWidth(double w) {
    if (w >= desktopL) return 240;
    if (w >= desktopS) return 220;
    if (w >= tablet) return 180; // Optimized for tablets
    return 0;
  }

  // ══════════════════════════════════════════════
  // SPACING TOKENS — reduced for tighter UI
  // ══════════════════════════════════════════════
  static EdgeInsets outerPadding(double w) {
    if (w < mobileM) return const EdgeInsets.all(8);
    if (w < mobileL) return const EdgeInsets.all(12);
    if (w < tablet) return const EdgeInsets.all(16);
    if (w < desktopS) return const EdgeInsets.all(20);
    return const EdgeInsets.all(24);
  }

  static double gutter(double w) {
    if (w < mobileM) return 8;
    if (w < mobileL) return 10;
    if (w < tablet) return 12;
    if (w < desktopS) return 16;
    return 20;
  }

  static double sectionGap(double w) {
    if (w < mobileM) return 16;
    if (w < mobileL) return 20;
    if (w < tablet) return 24;
    if (w < desktopS) return 32;
    return 36;
  }

  static EdgeInsets cardPadding(double w) {
    if (w < mobileM) return const EdgeInsets.all(8);
    if (w < mobileL) return const EdgeInsets.all(12);
    if (w < tablet) return const EdgeInsets.all(14);
    if (w < desktopS) return const EdgeInsets.all(16);
    return const EdgeInsets.all(20);
  }

  // ══════════════════════════════════════════════
  // TYPOGRAPHY SCALE — 1–2px smaller
  // ══════════════════════════════════════════════
  static TextStyle display1(double w) => TextStyle(
    fontSize: w < mobileL ? 20 : w < tablet ? 24 : w < desktopS ? 26 : w < desktopL ? 28 : 32,
    fontWeight: FontWeight.w700,
  );

  static TextStyle h2(double w) => TextStyle(
    fontSize: w < mobileL ? 17 : w < tablet ? 18 : w < desktopS ? 20 : w < desktopL ? 22 : 24,
    fontWeight: FontWeight.w600,
  );

  static TextStyle h3(double w) => TextStyle(
    fontSize: w < mobileL ? 15 : w < tablet ? 16 : w < desktopS ? 16 : w < desktopL ? 17 : 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle h4(double w) => TextStyle(
    fontSize: w < mobileL ? 13 : w < tablet ? 14 : w < desktopS ? 14 : w < desktopL ? 15 : 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle body(double w) {
    if (w < mobileM) return const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.5);
    if (w < mobileL) return const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, height: 1.5);
    if (w < tablet) return const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, height: 1.55);
    return const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.55);
  }

  static TextStyle small(double w) {
    if (w < mobileM) return const TextStyle(fontSize: 10);
    if (w < mobileL) return const TextStyle(fontSize: 11);
    return const TextStyle(fontSize: 12);
  }

  static TextStyle label(double w) {
    return const TextStyle(fontSize: 11, fontWeight: FontWeight.w500);
  }

  static TextStyle button(double w) {
    return const TextStyle(fontSize: 13, fontWeight: FontWeight.w500);
  }

  static TextStyle navItem(double w) {
    if (w < tablet) return const TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
    return const TextStyle(fontSize: 13, fontWeight: FontWeight.w500);
  }

  // ══════════════════════════════════════════════
  // COMPONENT SIZES
  // ══════════════════════════════════════════════
  static double inputHeight(double w) {
    if (w < desktopS) return 40;
    return 36;
  }

  static double buttonHeight(double w) {
    if (w < desktopS) return 40;
    return 36;
  }

  static double cardRadius(double w) {
    if (w < mobileL) return 8;
    if (w < tablet) return 10;
    if (w < desktopS) return 10;
    return 12;
  }

  static double inputRadius(double w) => 8;

  // ══════════════════════════════════════════════
  // LAYOUT
  // ══════════════════════════════════════════════
  static Widget maxWidthContainer(double screenWidth, Widget child) {
    if (screenWidth >= desktopL) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: desktopL),
        child: child,
      );
    }
    return child;
  }

  static bool statCardsTwoCol(double w) => w < mobileL;

  // ══════════════════════════════════════════════
  // Shared spacing scale
  // ══════════════════════════════════════════════
  static const double s2 = 2;
  static const double s4 = 4;
  static const double s6 = 6;
  static const double s8 = 8;
  static const double s10 = 10;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;
  static const double s56 = 56;
}