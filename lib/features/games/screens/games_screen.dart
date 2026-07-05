import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final games = [
      _GameItem(icon: Icons.grid_3x3_rounded, title: 'إكس أو', subtitle: 'العبا معاً', route: '/xo-game', gradient: AppColors.primaryGradient, isAvailable: true),
      _GameItem(icon: Icons.theater_comedy_rounded, title: 'الحقيقة أو الجرأة', subtitle: 'تحديات ممتعة', route: '/truth-dare', gradient: AppColors.roseGradient, isAvailable: true),
      _GameItem(icon: Icons.help_center_rounded, title: 'أسئلة تعارف', subtitle: 'اعرفا بعضكما أكثر', route: '/truth-dare', gradient: AppColors.cardGradient, isAvailable: true),
      _GameItem(icon: Icons.favorite_rounded, title: 'تحديات الحب', subtitle: 'تحديات رومانسية', route: '/games', gradient: AppColors.cardGradient, isAvailable: false),
      _GameItem(icon: Icons.image_search_rounded, title: 'تخمين الصورة', subtitle: 'من يعرف الآخر أكثر؟', route: '/games', gradient: AppColors.cardGradient, isAvailable: false),
      _GameItem(icon: Icons.star_rounded, title: 'أسئلة اليوم', subtitle: 'سؤال جديد كل يوم', route: '/games', gradient: AppColors.goldGradient, isAvailable: false),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withOpacity(0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('الألعاب', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 20)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: games.length,
          itemBuilder: (context, i) {
            final game = games[i];
            return GestureDetector(
              onTap: game.isAvailable ? () => context.push(game.route) : null,
              child: Container(
                decoration: BoxDecoration(
                  gradient: game.isAvailable ? game.gradient : null,
                  color: game.isAvailable ? null : AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                  boxShadow: game.isAvailable
                      ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))]
                      : null,
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(game.icon, size: 40, color: game.isAvailable ? Colors.white : AppColors.textHint),
                          const SizedBox(height: 12),
                          Text(
                            game.title,
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.bold,
                              color: game.isAvailable ? Colors.white : AppColors.textSecondary,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            game.subtitle,
                            style: GoogleFonts.tajawal(
                              color: game.isAvailable ? Colors.white70 : AppColors.textHint,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    if (!game.isAvailable)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Text(
                            'قريباً',
                            style: GoogleFonts.tajawal(color: AppColors.textHint, fontSize: 10),
                          ),
                        ),
                      ),
                  ],
                ),
              ).animate().scale(delay: Duration(milliseconds: i * 80)).fadeIn(delay: Duration(milliseconds: i * 80)),
            );
          },
        ),
      ),
    );
  }
}

class _GameItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final LinearGradient gradient;
  final bool isAvailable;

  _GameItem({required this.icon, required this.title, required this.subtitle, required this.route, required this.gradient, required this.isAvailable});
}
