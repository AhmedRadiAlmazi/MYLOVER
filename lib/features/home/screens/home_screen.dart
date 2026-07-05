import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/daily_quote_card.dart';
import '../widgets/love_counter_card.dart';
import '../widgets/quick_actions_grid.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final String _dailyQuote;

  @override
  void initState() {
    super.initState();
    _dailyQuote = AppConstants.loveQuotes[Random().nextInt(AppConstants.loveQuotes.length)];
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;
    final partner = ref.watch(currentPartnerProvider).value;

    int daysTogether = 0;
    if (currentUser != null && currentUser.relationshipStart != null) {
      daysTogether = DateTime.now().difference(currentUser.relationshipStart!).inDays;
    }

    final partnerName = partner?.name ?? 'شريكي';
    final partnerAvatar = partner?.avatarUrl ?? 'https://i.pravatar.cc/150?img=5';
    final myAvatar = currentUser?.avatarUrl ?? 'https://i.pravatar.cc/150?img=10';
    final isPartnerOnline = partner?.isOnline ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 80,
            floating: true,
            pinned: true,
            backgroundColor: AppColors.background.withOpacity(0.95),
            elevation: 0,
            title: Row(
              children: [
                // My Avatar (current user)
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.secondary.withOpacity(0.6), width: 2),
                    image: DecorationImage(
                      image: getSmartImageProvider(myAvatar),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Heart connector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.favorite_rounded,
                    color: AppColors.secondary,
                    size: 16,
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(1.2, 1.2),
                        duration: 800.ms,
                      ),
                ),

                // Partner Avatar with online status
                Stack(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                        image: DecorationImage(
                          image: getSmartImageProvider(partnerAvatar),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (isPartnerOnline)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.online,
                            border: Border.all(color: AppColors.background, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 10),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      partnerName,
                      style: GoogleFonts.tajawal(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isPartnerOnline ? AppColors.online : AppColors.offline,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPartnerOnline ? AppStrings.partnerOnline : 'غير متصل',
                          style: GoogleFonts.tajawal(
                            fontSize: 11,
                            color: isPartnerOnline
                                ? AppColors.online
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Spacer(),

                // Notifications Icon
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                  },
                ),
              ],
            ),
          ),

          // ── Body ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // Love Counter Card
                  LoveCounterCard(daysTogether: daysTogether)
                      .animate()
                      .slideY(begin: -0.2)
                      .fadeIn(duration: 500.ms),

                  const SizedBox(height: 20),

                  // Daily Quote Card
                  DailyQuoteCard(dailyQuote: _dailyQuote)
                      .animate()
                      .slideY(begin: 0.2, delay: 150.ms)
                      .fadeIn(delay: 150.ms, duration: 500.ms),

                  const SizedBox(height: 28),

                  // Section Title
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppStrings.discoverTogether,
                        style: GoogleFonts.tajawal(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 250.ms),

                  const SizedBox(height: 16),

                  // Quick Actions Grid
                  const QuickActionsGrid()
                      .animate()
                      .slideY(begin: 0.2, delay: 350.ms)
                      .fadeIn(delay: 350.ms, duration: 500.ms),

                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
