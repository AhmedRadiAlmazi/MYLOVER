import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import 'home_quick_action_card.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final items = _buildItems(context);
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }

  List<Widget> _buildItems(BuildContext context) {
    return [
      HomeQuickActionCard(
        icon: Icons.chat_bubble_rounded,
        label: 'الدردشة',
        gradient: const LinearGradient(
          colors: [Color(0xFF8B3FD9), Color(0xFFB57BEE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        glowColor: AppColors.primary,
        onTap: () {
          HapticFeedback.selectionClick();
          context.go('/chat'); // Switch tab in shell
        },
      ),
      HomeQuickActionCard(
        icon: Icons.photo_camera_rounded,
        label: 'الذكريات',
        gradient: const LinearGradient(
          colors: [Color(0xFFE5447A), Color(0xFFFF9CBB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        glowColor: AppColors.secondary,
        onTap: () {
          HapticFeedback.selectionClick();
          context.push('/memories'); // Memories is outside the shell stack, keep push
        },
      ),
      HomeQuickActionCard(
        icon: Icons.menu_book_rounded,
        label: 'اليوميات',
        gradient: const LinearGradient(
          colors: [Color(0xFF2D6A4F), Color(0xFF52B788)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        glowColor: const Color(0xFF52B788),
        onTap: () {
          HapticFeedback.selectionClick();
          context.push('/diary'); // Outside shell, keep push
        },
      ),
      HomeQuickActionCard(
        icon: Icons.calendar_today_rounded,
        label: 'التقويم',
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        glowColor: AppColors.info,
        onTap: () {
          HapticFeedback.selectionClick();
          context.go('/calendar'); // Switch tab in shell
        },
      ),
      HomeQuickActionCard(
        icon: Icons.card_giftcard_rounded,
        label: 'المفاجآت',
        gradient: const LinearGradient(
          colors: [Color(0xFFD4A017), Color(0xFFFFD700)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        glowColor: AppColors.accent,
        onTap: () {
          HapticFeedback.selectionClick();
          context.push('/surprise-box');
        },
      ),
      HomeQuickActionCard(
        icon: Icons.sports_esports_rounded,
        label: 'الألعاب',
        gradient: const LinearGradient(
          colors: [Color(0xFFBF360C), Color(0xFFFF7043)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        glowColor: const Color(0xFFFF7043),
        onTap: () {
          HapticFeedback.selectionClick();
          context.push('/games');
        },
      ),
      HomeQuickActionCard(
        icon: Icons.smart_toy_rounded,
        label: 'المساعد',
        gradient: const LinearGradient(
          colors: [Color(0xFF00695C), Color(0xFF4DB6AC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        glowColor: const Color(0xFF4DB6AC),
        onTap: () {
          HapticFeedback.selectionClick();
          context.push('/ai');
        },
      ),
      HomeQuickActionCard(
        icon: Icons.star_rounded,
        label: 'الأمنيات',
        gradient: const LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFFCE93D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        glowColor: const Color(0xFFCE93D8),
        onTap: () {
          HapticFeedback.selectionClick();
          context.push('/wishes');
        },
      ),
      HomeQuickActionCard(
        icon: Icons.auto_stories_rounded,
        label: 'كتابنا',
        gradient: const LinearGradient(
          colors: [Color(0xFF880E4F), Color(0xFFF48FB1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        glowColor: const Color(0xFFF48FB1),
        onTap: () {
          HapticFeedback.selectionClick();
          context.push('/shared-book');
        },
      ),
      HomeQuickActionCard(
        icon: Icons.bar_chart_rounded,
        label: 'إحصائيات',
        gradient: const LinearGradient(
          colors: [Color(0xFF004D40), Color(0xFF26A69A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        glowColor: const Color(0xFF26A69A),
        onTap: () {
          HapticFeedback.selectionClick();
          context.push('/stats');
        },
      ),
      HomeQuickActionCard(
        icon: Icons.lock_rounded,
        label: 'الأسرار',
        gradient: const LinearGradient(
          colors: [Color(0xFF37474F), Color(0xFF78909C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        glowColor: const Color(0xFF78909C),
        onTap: () {
          HapticFeedback.selectionClick();
          context.push('/secret-box');
        },
      ),
      HomeQuickActionCard(
        icon: Icons.music_note_rounded,
        label: 'أغانينا',
        gradient: const LinearGradient(
          colors: [Color(0xFF4527A0), Color(0xFF9575CD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        glowColor: const Color(0xFF9575CD),
        onTap: () {
          HapticFeedback.selectionClick();
          context.push('/music');
        },
      ),
    ];
  }
}
