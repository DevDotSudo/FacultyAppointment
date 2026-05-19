import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Modern Flat Design Palette ──
  // Primary Colors (Blue)
  static const Color primary = Color(0xFF2563EB);       // Blue 600
  static const Color primaryDark = Color(0xFF1E40AF);   // Blue 700
  static const Color primaryLight = Color(0xFF3B82F6);  // Blue 500
  static const Color primaryBg = Color(0xFFDCE7FF);     // Blue 100

  // Accent Colors (Emerald)
  static const Color accent = Color(0xFF10B981);        // Emerald 500
  static const Color accentDark = Color(0xFF059669);    // Emerald 600
  static const Color accentLight = Color(0xFF34D399);   // Emerald 400

  // ── Background Colors (Less White) ──
  // Light Theme
  static const Color lightBg = Color(0xFFF1F5F9);       // Slate 100
  static const Color lightSurface = Color(0xFFFFFFFF);  // White
  static const Color lightCardBg = Color(0xFFFFFFFF);   // White
  static const Color lightBorder = Color(0xFFE2E8F0);   // Slate 200
  static const Color lightDivider = Color(0xFFF1F5F9);  // Slate 100
  static const Color lightInputBg = Color(0xFFF8FAFC);  // Slate 50
  static const Color lightSidebarBg = Color(0xFF1E293B); // Slate 800
  static const Color lightHeaderBg = Color(0xFFFFFFFF); // White

  // Dark Theme
  static const Color darkBg = Color(0xFF0F172A);        // Slate 900
  static const Color darkSurface = Color(0xFF1E293B);   // Slate 800
  static const Color darkCardBg = Color(0xFF1E293B);    // Slate 800
  static const Color darkBorder = Color(0xFF334155);    // Slate 700
  static const Color darkDivider = Color(0xFF1E293B);   // Slate 800
  static const Color darkInputBg = Color(0xFF334155);   // Slate 700
  static const Color darkSidebarBg = Color(0xFF020617); // Slate 950
  static const Color darkHeaderBg = Color(0xFF1E293B);  // Slate 800

  // ── Text Colors ──
  static const Color lightTextPrimary = Color(0xFF0F172A);   // Slate 900
  static const Color lightTextSecondary = Color(0xFF64748B); // Slate 500
  static const Color lightTextMuted = Color(0xFF94A3B8);     // Slate 400
  static const Color darkTextPrimary = Color(0xFFF8FAFC);    // Slate 50
  static const Color darkTextSecondary = Color(0xFF94A3B8);  // Slate 400
  static const Color darkTextMuted = Color(0xFF64748B);      // Slate 500

  // ── Status Colors ──
  static const Color success = Color(0xFF10B981);       // Emerald 500
  static const Color warning = Color(0xFFF59E0B);       // Amber 500
  static const Color danger = Color(0xFFEF4444);        // Red 500
  static const Color info = Color(0xFF3B82F6);          // Blue 500

  static const Color successBg = Color(0xFFD1FAE5);     // Emerald 100
  static const Color warningBg = Color(0xFFFEF3C7);     // Amber 100
  static const Color dangerBg = Color(0xFFFEE2E2);      // Red 100
  static const Color infoBg = Color(0xFFDBEAFE);        // Blue 100

  static const Color successText = Color(0xFF065F46);   // Emerald 800
  static const Color warningText = Color(0xFF92400E);   // Amber 800
  static const Color dangerText = Color(0xFF991B1B);    // Red 800
  static const Color infoText = Color(0xFF1E40AF);      // Blue 700

  // ── Status Colors (Appointments) ──
  static const Color statusPending = Color(0xFFF59E0B);      // Amber 500
  static const Color statusAccepted = Color(0xFF10B981);     // Emerald 500
  static const Color statusRejected = Color(0xFFEF4444);     // Red 500
  static const Color statusCancelled = Color(0xFF64748B);    // Slate 500
  static const Color statusCompleted = Color(0xFF8B5CF6);    // Purple 500

  static const Color statusPendingBg = Color(0xFFFEF3C7);    // Amber 100
  static const Color statusAcceptedBg = Color(0xFFD1FAE5);   // Emerald 100
  static const Color statusRejectedBg = Color(0xFFFEE2E2);   // Red 100
  static const Color statusCancelledBg = Color(0xFFF1F5F9);  // Slate 100
  static const Color statusCompletedBg = Color(0xFFEDE9FE);  // Purple 100

  static const Color statusPendingText = Color(0xFF92400E);  // Amber 800
  static const Color statusAcceptedText = Color(0xFF065F46); // Emerald 800
  static const Color statusRejectedText = Color(0xFF991B1B); // Red 800
  static const Color statusCancelledText = Color(0xFF475569); // Slate 600
  static const Color statusCompletedText = Color(0xFF6B21A8); // Purple 800

  // ── Neutrals (Slate Scale) ──
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);

  // ── Gradients (Minimal for Flat Design) ──
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
  );
  static const Gradient accentGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  // ── BACKWARD COMPATIBLE ALIASES ──
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = slate50;
  static const Color gray100 = slate100;
  static const Color gray200 = slate200;
  static const Color gray300 = slate300;
  static const Color gray400 = slate400;
  static const Color gray500 = slate500;
  static const Color gray600 = slate600;
  static const Color gray700 = slate700;
  static const Color gray800 = slate800;
  static const Color gray900 = slate900;

  static const Color textMuted = slate400;
  static const Color textPrimary = slate900;
  static const Color textSecondary = slate500;
  static const Color primaryBlue = primary;
  static const Color lightGrayBg = slate50;
  static const Color cardWhite = white;
  static const Color borderGray = slate200;
  static const Color fieldBorder = slate200;
  static const Color fieldFill = slate100;
  static const Color textDark = slate900;
  static const Color textBody = slate600;
  static const Color textHint = slate400;
  static const Color pageBackground = slate50;
  static const Color background = slate50;
  static const Color cardBg = white;
  static const Color darkNavy = slate900;
  static const Color sidebarDark = slate900;
  static const Color sidebarMid = slate800;
  static const Color activeNavBg = primary;
  static const Color darkCard = darkCardBg;
  static const Color darkText = darkTextPrimary;
  static const Color darkMuted = darkTextSecondary;
  static const Color darkHighlight = danger;
  static const Color cardLight = white;
  static const Color dividerLight = slate100;
  static const Color darkAccent = slate800;
  static const Color darkNavActive = primary;
  static const Color darkSuccess = success;
  static const Color darkWarning = warning;
  static const Color darkDanger = danger;
  static const Color darkInfo = info;
  static const Color lightNavActive = primary;
  static const Color lightSuccess = success;
  static const Color lightWarning = warning;
  static const Color lightDanger = danger;
  static const Color lightInfo = info;
}