import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Backgrounds ─────────────────────────────────────
  static const Color background = Color(0xFF080810);
  static const Color surface = Color(0xFF10101C);
  static const Color card = Color(0xFF1A1A2E);
  static const Color cardLight = Color(0xFF22223A);
  static const Color overlay = Color(0xFF0D0D1A);

  // ── Brand Purple ─────────────────────────────────────
  static const Color primary = Color(0xFFB57BEE);
  static const Color primaryDark = Color(0xFF8B3FD9);
  static const Color primaryLight = Color(0xFFD4A4FF);
  static const Color primaryContainer = Color(0xFF2D1B4E);

  // ── Brand Rose ───────────────────────────────────────
  static const Color secondary = Color(0xFFFF6B9D);
  static const Color secondaryDark = Color(0xFFE5447A);
  static const Color secondaryLight = Color(0xFFFF9CBB);
  static const Color secondaryContainer = Color(0xFF4A1A2E);

  // ── Accent Gold ──────────────────────────────────────
  static const Color accent = Color(0xFFFFD700);
  static const Color accentSoft = Color(0xFFFFE57F);
  static const Color accentContainer = Color(0xFF3A3000);

  // ── Text ─────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF0F0FF);
  static const Color textSecondary = Color(0xFFB0B0CC);
  static const Color textHint = Color(0xFF70708A);
  static const Color textDisabled = Color(0xFF404050);

  // ── Utility ──────────────────────────────────────────
  static const Color divider = Color(0xFF252535);
  static const Color success = Color(0xFF66BB6A);
  static const Color successContainer = Color(0xFF1A3A1A);
  static const Color error = Color(0xFFEF5350);
  static const Color errorContainer = Color(0xFF3A1515);
  static const Color warning = Color(0xFFFFA726);
  static const Color warningContainer = Color(0xFF3A2800);
  static const Color info = Color(0xFF42A5F5);

  // ── Online Status ────────────────────────────────────
  static const Color online = Color(0xFF66BB6A);
  static const Color offline = Color(0xFF616161);
  static const Color away = Color(0xFFFFA726);

  // ── Gradients ────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B3FD9), Color(0xFFFF6B9D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradientVertical = LinearGradient(
    colors: [Color(0xFF8B3FD9), Color(0xFFFF6B9D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF080810), Color(0xFF10101C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF141425)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient roseGradient = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFFF9CBB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF8B3FD9), Color(0xFFB57BEE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFB300)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient deepNightGradient = LinearGradient(
    colors: [Color(0xFF080810), Color(0xFF1A0A2E), Color(0xFF0A0A20)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient twilightGradient = LinearGradient(
    colors: [Color(0xFF1A0A3E), Color(0xFF3D1A6E), Color(0xFF8B3FD9)],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFF8B3FD9), Color(0xFFFF6B9D), Color(0xFFFFD700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Glass Effect ─────────────────────────────────────
  static Color glassWhite = Colors.white.withOpacity(0.05);
  static Color glassBorder = Colors.white.withOpacity(0.1);
  static Color glassPrimary = const Color(0xFFB57BEE).withOpacity(0.1);
}
