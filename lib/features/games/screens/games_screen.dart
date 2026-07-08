import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../providers/games_provider.dart';

class GamesScreen extends ConsumerWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userGameStatsProvider);
    final stats = statsAsync.value;
    final points = stats?.points ?? 0;
    final badge = stats?.badges.isNotEmpty == true ? stats!.badges.last : 'شريك مخلص';

    final games = [
      _GameItem(
        icon: Icons.grid_3x3_rounded,
        title: 'لعبة XO',
        subtitle: 'تحدي الذكاء التقليدي بينكما',
        route: '/xo-game',
        gradient: AppColors.primaryGradient,
        isAvailable: true,
      ),
      _GameItem(
        icon: Icons.help_center_rounded,
        title: 'من يعرف الآخر أكثر؟',
        subtitle: 'أجب عن أسئلة شريكك المخصصة',
        route: '/who-knows',
        gradient: AppColors.roseGradient,
        isAvailable: true,
      ),
      _GameItem(
        icon: Icons.theater_comedy_rounded,
        title: 'الحقيقة أو التحدي',
        subtitle: 'ألعاب صراحة وتحديات مشوقة',
        route: '/truth-dare',
        gradient: AppColors.purpleGradient,
        isAvailable: true,
      ),
      _GameItem(
        icon: Icons.edit_note_rounded,
        title: 'أكمل الجملة',
        subtitle: 'اكتبا معاً واكشفا الأجوبة',
        route: '/complete-sentence',
        gradient: AppColors.goldGradient,
        isAvailable: true,
      ),
      _GameItem(
        icon: Icons.palette_rounded,
        title: 'ارسم وخمن',
        subtitle: 'ارسم لشريكك ودعه يخمنها مباشرة',
        route: '/draw-guess',
        gradient: const LinearGradient(colors: [Color(0xFF2D6A4F), Color(0xFF52B788)]),
        isAvailable: true,
      ),
      _GameItem(
        icon: Icons.mic_rounded,
        title: 'تحدي الصوت',
        subtitle: 'سجلا أصواتكما وقيما الأجمل',
        route: '/voice-challenge',
        gradient: const LinearGradient(colors: [Color(0xFF880E4F), Color(0xFFF48FB1)]),
        isAvailable: true,
      ),
      _GameItem(
        icon: Icons.casino_rounded,
        title: 'عجلة المفاجآت',
        subtitle: 'أدر العجلة ونفّذ الطلب الرومانسي',
        route: '/wheel-surprises',
        gradient: const LinearGradient(colors: [Color(0xFF004D40), Color(0xFF26A69A)]),
        isAvailable: true,
      ),
      _GameItem(
        icon: Icons.photo_library_rounded,
        title: 'لعبة الذكريات',
        subtitle: 'اختبرا معلوماتكما عن صوركما القديمة',
        route: '/memories-quiz',
        gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF42A5F5)]),
        isAvailable: true,
      ),
      _GameItem(
        icon: Icons.image_search_rounded,
        title: 'خمن الصورة',
        subtitle: 'ازل الغباش تدريجياً وخمن الصورة',
        route: '/guess-picture',
        gradient: const LinearGradient(colors: [Color(0xFFBF360C), Color(0xFFFF7043)]),
        isAvailable: true,
      ),
      _GameItem(
        icon: Icons.emoji_events_rounded,
        title: 'لوحة الإنجازات',
        subtitle: 'الأوسمة والنقاط والترتيب بينكما',
        route: '/achievements',
        gradient: const LinearGradient(colors: [Color(0xFFD4A017), Color(0xFFE5A93C)]),
        isAvailable: true,
      ),
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
        title: Text(
          'ألعابنا 🎮',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // ── Stats Header Widget ──
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1D1B26), Color(0xFF2D2A3D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'رصيد نقاطك الحالي',
                          style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '$points',
                              style: GoogleFonts.tajawal(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.favorite_rounded, color: AppColors.secondary, size: 24)
                                .animate(onPlay: (c) => c.repeat())
                                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 800.ms),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'لقبك الحالي',
                          style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                          ),
                          child: Text(
                            badge,
                            style: GoogleFonts.tajawal(
                              color: AppColors.secondary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().slideY(begin: -0.1).fadeIn(),
          ),

          // ── Games Grid ──
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.95,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final game = games[i];
                  return GestureDetector(
                    onTap: game.isAvailable ? () => context.push(game.route) : null,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: game.isAvailable ? game.gradient : null,
                        color: game.isAvailable ? null : AppColors.card,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                        boxShadow: game.isAvailable
                            ? [
                                BoxShadow(
                                  color: game.gradient.colors.first.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -10,
                            bottom: -10,
                            child: Icon(
                              game.icon,
                              size: 80,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    game.icon,
                                    size: 26,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  game.title,
                                  style: GoogleFonts.tajawal(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  game.subtitle,
                                  style: GoogleFonts.tajawal(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().scale(delay: Duration(milliseconds: i * 50)).fadeIn(delay: Duration(milliseconds: i * 50));
                },
                childCount: games.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
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

  _GameItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.gradient,
    required this.isAvailable,
  });
}
