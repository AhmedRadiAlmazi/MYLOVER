import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

class LoveCounterCard extends StatelessWidget {
  const LoveCounterCard({
    super.key,
    required this.daysTogether,
  });

  final int daysTogether;

  String _getLabel() {
    if (daysTogether >= 365) return AppStrings.years;
    if (daysTogether >= 30) return AppStrings.months;
    return AppStrings.days;
  }

  int _getDisplayValue() {
    if (daysTogether >= 365) return (daysTogether / 365).floor();
    if (daysTogether >= 30) return (daysTogether / 30).floor();
    return daysTogether;
  }

  String _getSubtitle() {
    if (daysTogether >= 365) {
      final months = ((daysTogether % 365) / 30).floor();
      if (months > 0) return '$months شهر إضافي';
      return '$daysTogether يوم معاً';
    }
    if (daysTogether >= 30) {
      final days = daysTogether % 30;
      if (days > 0) return '$days يوم إضافي';
      return '$daysTogether يوم معاً';
    }
    return '$daysTogether يوماً من الجمال معاً';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background: simplified heart symbol instead of logo
          Positioned(
            right: -20,
            top: -20,
            child: Opacity(
              opacity: 0.10,
              child: Icon(
                Icons.favorite_rounded,
                size: 180,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Opacity(
              opacity: 0.06,
              child: Icon(
                Icons.all_inclusive_rounded,
                size: 160,
                color: Colors.white,
              ),
            ),
          ),

          // Subtle top highlight
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.togetherSince,
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.85),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_getDisplayValue()}',
                      style: GoogleFonts.tajawal(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                        height: 1,
                        shadows: [
                          Shadow(
                            color: AppColors.accent.withOpacity(0.5),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        _getLabel(),
                        style: GoogleFonts.tajawal(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getSubtitle(),
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
