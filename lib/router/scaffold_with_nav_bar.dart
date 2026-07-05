import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    HapticFeedback.selectionClick();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 24),
        height: 58,
        width: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.5),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              HapticFeedback.mediumImpact();
              context.push('/memories');
            },
            child: const Icon(
              Icons.add_photo_alternate_rounded,
              size: 26,
              color: Colors.white,
            ),
          ),
        ),
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: BottomAppBar(
            color: AppColors.surface.withOpacity(0.88),
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            elevation: 0,
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  _buildNavItem(0, Icons.home_rounded, AppStrings.navHome),
                  _buildNavItem(1, Icons.chat_bubble_rounded, AppStrings.navChat),
                  const SizedBox(width: 52), // Space for FAB notch
                  _buildNavItem(2, Icons.calendar_today_rounded, AppStrings.navCalendar),
                  _buildNavItem(3, Icons.person_rounded, AppStrings.navProfile),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = navigationShell.currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _goBranch(index),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated pill background around icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 10 : 4,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textHint,
                size: 21,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textHint,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
