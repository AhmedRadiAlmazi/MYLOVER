import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Backgrounds & Cards ──────────────────────────────
  static const Color background = Color(0xFFFFF9FB); // #FFF9FB
  static const Color surface = Color(0xFFFFF4F8);
  static const Color card = Color(0xFFFFFFFF);     // #FFFFFF
  static const Color cardLight = Color(0xFFFFF0F5);
  static const Color overlay = Color(0xFF4A1A2E);

  // ── Brand Primary (#A64D79) ──────────────────────────
  static const Color primary = Color(0xFFA64D79);
  static const Color primaryDark = Color(0xFF7D3257);
  static const Color primaryLight = Color(0xFFC8749E);
  static const Color primaryContainer = Color(0xFFFAF0F4);

  // ── Secondary Brand / Buttons (#D98CA3) ──────────────
  static const Color secondary = Color(0xFFD98CA3);
  static const Color secondaryDark = Color(0xFFB86880);
  static const Color secondaryLight = Color(0xFFF5B8C9);
  static const Color secondaryContainer = Color(0xFFFFF0F5);
  static const Color onSecondary = Color(0xFF3D232E);

  // ── Hearts & Reactions (#E75480) ────────────────────
  static const Color heart = Color(0xFFE75480);
  static const Color heartLight = Color(0xFFFF85A6);

  // ── Luxury Accent Gold (#D4AF37) ────────────────────
  static const Color accent = Color(0xFFD4AF37);
  static const Color accentSoft = Color(0xFFF4D068);
  static const Color accentContainer = Color(0xFFFFF8E7);

  // ── Text Colors ─────────────────────────────────────
  static const Color textPrimary = Color(0xFF2D1E27);
  static const Color textSecondary = Color(0xFF6A5260);
  static const Color textHint = Color(0xFF9E8694);
  static const Color textDisabled = Color(0xFFD2C4CC);

  // ── Utility ──────────────────────────────────────────
  static const Color divider = Color(0xFFF0E2E7);
  static const Color success = Color(0xFF4CAF50);
  static const Color successContainer = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFE53935);
  static const Color errorContainer = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFFFA000);
  static const Color warningContainer = Color(0xFFFFF8E1);
  static const Color info = Color(0xFF1E88E5);

  // ── Online Status ────────────────────────────────────
  static const Color online = Color(0xFF4CAF50);
  static const Color offline = Color(0xFF9E8694);
  static const Color away = Color(0xFFFFA000);

  // ── Gradients ────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFA64D79), Color(0xFFE75480)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradientVertical = LinearGradient(
    colors: [Color(0xFFA64D79), Color(0xFFE75480)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFFFF9FB), Color(0xFFFFF0F5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFFF7FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient roseGradient = LinearGradient(
    colors: [Color(0xFFE75480), Color(0xFFD98CA3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFFA64D79), Color(0xFFC8749E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFF4D068)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient deepNightGradient = LinearGradient(
    colors: [Color(0xFF1E1018), Color(0xFF2D1524), Color(0xFF180A13)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient twilightGradient = LinearGradient(
    colors: [Color(0xFF2D1524), Color(0xFF52233C), Color(0xFFA64D79)],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFA64D79), Color(0xFFE75480), Color(0xFFD4AF37)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Glass Effect ─────────────────────────────────────
  static Color glassWhite = Colors.white.withOpacity(0.85);
  static Color glassBorder = const Color(0xFFA64D79).withOpacity(0.15);
  static Color glassPrimary = const Color(0xFFA64D79).withOpacity(0.08);
}
