import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/games_provider.dart';
import '../models/game_models.dart';

class XOGameScreen extends ConsumerWidget {
  const XOGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupleId = ref.watch(coupleIdProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final partner = ref.watch(currentPartnerProvider).value;
    final gameAsync = ref.watch(xoGameStreamProvider);

    if (coupleId == null || currentUser == null || partner == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final game = gameAsync.value;

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
          'لعبة إكس أو 🎮',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: game == null
          ? _buildStartGameView(context, ref, coupleId, currentUser.id, partner.id, partner.name)
          : _buildGameBoardView(context, ref, coupleId, currentUser.id, partner.id, partner.name, game),
    );
  }

  Widget _buildStartGameView(
    BuildContext context,
    WidgetRef ref,
    String coupleId,
    String myId,
    String partnerId,
    String partnerName,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🎮 XO تحدي',
              style: GoogleFonts.tajawal(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              'العبا معاً إكس أو مباشرة بمزامنة فورية!',
              style: GoogleFonts.tajawal(fontSize: 15, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            GradientButton(
              text: 'ابدأ لعبة جديدة 🚀',
              onPressed: () async {
                await ref.read(gameServiceProvider).startXOGame(coupleId, myId, partnerId);
              },
              width: 250,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameBoardView(
    BuildContext context,
    WidgetRef ref,
    String coupleId,
    String myId,
    String partnerId,
    String partnerName,
    XOGameState game,
  ) {
    final mySymbol = myId == game.playerXId ? "X" : "O";
    final partnerSymbol = partnerId == game.playerXId ? "X" : "O";

    final myScore = game.score[myId] ?? 0;
    final partnerScore = game.score[partnerId] ?? 0;
    final drawScore = game.score['draw'] ?? 0;

    String statusText;
    bool isMyTurn = game.currentTurnId == myId;
    if (game.status == 'active') {
      statusText = isMyTurn ? 'دورك الآن ($mySymbol)' : 'دور $partnerName ($partnerSymbol)...';
    } else if (game.winnerId == 'draw') {
      statusText = 'تعادل! 🤝';
    } else {
      statusText = game.winnerId == myId ? '🎉 فزت بالتحدي! (+5 نقاط)' : '🎉 فاز $partnerName!';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Scorecard
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ScoreCard(label: 'أنا ($mySymbol)', score: myScore, color: AppColors.primary),
              Column(
                children: [
                  Text('تعادل', style: GoogleFonts.tajawal(color: AppColors.textHint, fontSize: 12)),
                  Text('$drawScore', style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              _ScoreCard(label: '$partnerName ($partnerSymbol)', score: partnerScore, color: AppColors.secondary),
            ],
          ),
          const SizedBox(height: 40),

          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isMyTurn && game.status == 'active' ? AppColors.primary.withOpacity(0.15) : AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isMyTurn && game.status == 'active' ? AppColors.primary.withOpacity(0.3) : AppColors.divider,
              ),
            ),
            child: Text(
              statusText,
              style: GoogleFonts.tajawal(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: game.status == 'finished' ? AppColors.accent : Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ).animate(key: ValueKey(statusText)).scale(duration: 200.ms),
          const SizedBox(height: 40),

          // Grid Board
          SizedBox(
            width: 300,
            height: 300,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: 9,
              itemBuilder: (context, i) {
                final cellValue = game.board[i];
                return GestureDetector(
                  onTap: game.status == 'active' && isMyTurn && cellValue.isEmpty
                      ? () => ref.read(gameServiceProvider).makeXOMove(coupleId, i, myId)
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Center(
                      child: Text(
                        cellValue,
                        style: GoogleFonts.tajawal(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: cellValue == "X" ? AppColors.primary : AppColors.secondary,
                        ),
                      ).animate(key: ValueKey(cellValue)).scale(duration: 150.ms),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 48),

          // Restart button
          GradientButton(
            text: game.status == 'finished' ? 'ابدأ من جديد 🔄' : 'إعادة تهيئة اللعبة 🔄',
            onPressed: () async {
              // Reset board but keep score
              await ref.read(gameServiceProvider).startXOGame(coupleId, myId, partnerId);
            },
            width: 200,
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.label, required this.score, required this.color});
  final String label;
  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.tajawal(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('$score', style: GoogleFonts.tajawal(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
