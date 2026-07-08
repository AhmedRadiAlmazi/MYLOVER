import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/games_provider.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).value;
    final partner = ref.watch(currentPartnerProvider).value;
    
    final myStatsAsync = ref.watch(userGameStatsProvider);
    final partnerStatsAsync = ref.watch(partnerGameStatsProvider);

    if (currentUser == null || partner == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final myStats = myStatsAsync.value;
    final partnerStats = partnerStatsAsync.value;

    final myPoints = myStats?.points ?? 0;
    final partnerPoints = partnerStats?.points ?? 0;

    final allBadges = [
      _BadgeItem(name: 'ملك XO', desc: 'فز بـ 5 مباريات في لعبة XO', icon: Icons.grid_3x3_rounded),
      _BadgeItem(name: 'خبير الأسئلة', desc: 'أجب بشكل صحيح عن 5 أسئلة تعارف', icon: Icons.psychology_rounded),
      _BadgeItem(name: 'أفضل رسام', desc: 'خمن الشريك رسمتك 3 مرات بنجاح', icon: Icons.palette_rounded),
      _BadgeItem(name: 'أجمل صوت', desc: 'احصل على 5 نجوم في 3 تحديات صوتية', icon: Icons.mic_rounded),
      _BadgeItem(name: 'بطل التحديات', desc: 'أنجز 10 تحديات مخصصة ويومية', icon: Icons.task_alt_rounded),
      _BadgeItem(name: 'روح واحدة', desc: 'اجمع 200 نقطة إجمالية بالتطبيق', icon: Icons.favorite_rounded),
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
          'لوحة الإنجازات والأوسمة 🏆',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Leaderboard row
            Text(
              'الترتيب بينكما 👑',
              style: GoogleFonts.tajawal(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _LeaderboardCard(
                    name: 'أنا',
                    points: myPoints,
                    isLeader: myPoints >= partnerPoints,
                    avatarUrl: currentUser.avatarUrl,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _LeaderboardCard(
                    name: partner.name,
                    points: partnerPoints,
                    isLeader: partnerPoints >= myPoints,
                    avatarUrl: partner.avatarUrl,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Victory stats
            Text(
              'تفاصيل إنجازاتي 🏆',
              style: GoogleFonts.tajawal(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  _StatRow(label: 'انتصارات إكس أو', value: myStats?.xoWins ?? 0),
                  const Divider(color: AppColors.divider),
                  _StatRow(label: 'أسئلة تمت الإجابة عليها', value: myStats?.whoKnowsWins ?? 0),
                  const Divider(color: AppColors.divider),
                  _StatRow(label: 'تخمينات رسم ناجحة', value: myStats?.drawGuessWins ?? 0),
                  const Divider(color: AppColors.divider),
                  _StatRow(label: 'أصوات تم تقييمها', value: myStats?.voiceChallengeWins ?? 0),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Badges grid
            Text(
              'الأوسمة المفتوحة 🎖️',
              style: GoogleFonts.tajawal(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: allBadges.length,
              itemBuilder: (context, i) {
                final b = allBadges[i];
                final isUnlocked = myStats?.badges.contains(b.name) ?? false;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUnlocked ? AppColors.primary.withOpacity(0.1) : AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isUnlocked ? AppColors.primary.withOpacity(0.4) : Colors.white.withOpacity(0.05),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        b.icon,
                        size: 38,
                        color: isUnlocked ? AppColors.primary : AppColors.textHint,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        b.name,
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? Colors.white : AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        b.desc,
                        style: GoogleFonts.tajawal(color: AppColors.textHint, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  const _LeaderboardCard({
    required this.name,
    required this.points,
    required this.isLeader,
    this.avatarUrl,
  });

  final String name;
  final int points;
  final bool isLeader;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLeader ? AppColors.primary.withOpacity(0.4) : Colors.white.withOpacity(0.05),
          width: isLeader ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(avatarUrl ?? 'https://i.pravatar.cc/150'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (isLeader)
                const CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.amber,
                  child: Icon(Icons.star, size: 12, color: Colors.white),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            '$points نقطة',
            style: GoogleFonts.tajawal(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 14)),
          Text('$value', style: GoogleFonts.tajawal(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _BadgeItem {
  final String name;
  final String desc;
  final IconData icon;

  _BadgeItem({required this.name, required this.desc, required this.icon});
}
