import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';

enum Player { none, x, o }

final boardProvider = StateProvider<List<Player>>((ref) => List.filled(9, Player.none));
final currentPlayerProvider = StateProvider<Player>((ref) => Player.x);
final scoresProvider = StateProvider<Map<String, int>>((ref) => {'x': 0, 'o': 0, 'draw': 0});
final winnerProvider = StateProvider<Player?>((ref) => null);

class XOGameScreen extends ConsumerWidget {
  const XOGameScreen({super.key});

  List<int>? _checkWin(List<Player> board) {
    const wins = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];
    for (final w in wins) {
      if (board[w[0]] != Player.none && board[w[0]] == board[w[1]] && board[w[1]] == board[w[2]]) return w;
    }
    return null;
  }

  bool _isBoardFull(List<Player> board) => board.every((p) => p != Player.none);

  void _handleTap(int index, WidgetRef ref) {
    final board = ref.read(boardProvider);
    final current = ref.read(currentPlayerProvider);
    final winner = ref.read(winnerProvider);
    if (board[index] != Player.none || winner != null) return;

    final newBoard = List<Player>.from(board);
    newBoard[index] = current;
    ref.read(boardProvider.notifier).state = newBoard;

    final winLine = _checkWin(newBoard);
    if (winLine != null) {
      ref.read(winnerProvider.notifier).state = current;
      final scores = Map<String, int>.from(ref.read(scoresProvider));
      scores[current == Player.x ? 'x' : 'o'] = (scores[current == Player.x ? 'x' : 'o'] ?? 0) + 1;
      ref.read(scoresProvider.notifier).state = scores;
    } else if (_isBoardFull(newBoard)) {
      ref.read(winnerProvider.notifier).state = Player.none; // Draw
      final scores = Map<String, int>.from(ref.read(scoresProvider));
      scores['draw'] = (scores['draw'] ?? 0) + 1;
      ref.read(scoresProvider.notifier).state = scores;
    } else {
      ref.read(currentPlayerProvider.notifier).state = current == Player.x ? Player.o : Player.x;
    }
  }

  void _reset(WidgetRef ref) {
    ref.read(boardProvider.notifier).state = List.filled(9, Player.none);
    ref.read(currentPlayerProvider.notifier).state = Player.x;
    ref.read(winnerProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(boardProvider);
    final current = ref.watch(currentPlayerProvider);
    final winner = ref.watch(winnerProvider);
    final scores = ref.watch(scoresProvider);

    String statusText;
    if (winner == null) {
      statusText = current == Player.x ? 'دور أنا (X)' : 'دور شريكي/شريكتي (O)';
    } else if (winner == Player.none) {
      statusText = 'تعادل! 🤝';
    } else {
      statusText = winner == Player.x ? '🎉 أنا فزت!' : '🎉 شريكي/شريكتي فاز!';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withOpacity(0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('إكس أو 🎮', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 20)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Score Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ScoreCard(label: 'أنا (X)', score: scores['x'] ?? 0, color: AppColors.primary),
                Column(
                  children: [
                    Text('تعادل', style: GoogleFonts.tajawal(color: AppColors.textHint, fontSize: 12)),
                    Text('${scores['draw'] ?? 0}', style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                _ScoreCard(label: 'شريكي (O)', score: scores['o'] ?? 0, color: AppColors.secondary),
              ],
            ),

            const SizedBox(height: 32),

            // Status
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                statusText,
                key: ValueKey(statusText),
                style: GoogleFonts.tajawal(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: winner != null ? AppColors.accent : AppColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Board
            SizedBox(
              width: 300,
              height: 300,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: 9,
                itemBuilder: (context, i) {
                  return GestureDetector(
                    onTap: () => _handleTap(i, ref),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Center(
                        child: board[i] == Player.x
                            ? Text('X', style: GoogleFonts.tajawal(fontSize: 44, fontWeight: FontWeight.bold, color: AppColors.primary))
                                .animate().scale(duration: 200.ms)
                            : board[i] == Player.o
                                ? Text('O', style: GoogleFonts.tajawal(fontSize: 44, fontWeight: FontWeight.bold, color: AppColors.secondary))
                                    .animate().scale(duration: 200.ms)
                                : null,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 40),

            GradientButton(
              text: 'لعبة جديدة 🔄',
              onPressed: () => _reset(ref),
              width: 200,
            ),
          ],
        ),
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
        Text(label, style: GoogleFonts.tajawal(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
        Text('$score', style: GoogleFonts.tajawal(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
