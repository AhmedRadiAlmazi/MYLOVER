import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_universe/features/games/models/game_models.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/games_provider.dart';

class CompleteSentenceScreen extends ConsumerStatefulWidget {
  const CompleteSentenceScreen({super.key});

  @override
  ConsumerState<CompleteSentenceScreen> createState() => _CompleteSentenceScreenState();
}

class _CompleteSentenceScreenState extends ConsumerState<CompleteSentenceScreen> {
  final TextEditingController _answerController = TextEditingController();
  final List<String> _prompts = [
    'أكثر شيء أحبه فيك هو...',
    'أجمل ذكرى عشناها معاً كانت في...',
    'أول شيء لفت انتباهي فيك...',
    'لو كان بإمكاننا السفر الآن، سنذهب إلى...',
    'أشعر بالأمان والراحة معك عندما...',
    'أتمنى أن نفعل هذا الشيء معاً قريباً وهو...',
    'الكلمة التي تصف علاقتنا في رأيي هي...',
  ];

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coupleId = ref.watch(coupleIdProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final partner = ref.watch(currentPartnerProvider).value;
    final gameAsync = ref.watch(completeSentenceGameStreamProvider);

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
          'أكمل الجملة ✍️',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: game == null
            ? _buildStartGameView(coupleId, currentUser.id, partner.id, partner.name)
            : _buildGameView(coupleId, currentUser.id, partner.name, game),
      ),
    );
  }

  Widget _buildStartGameView(String coupleId, String myId, String partnerId, String partnerName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Text('💌', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 24),
          Text(
            'لعبة أكمل الجملة',
            style: GoogleFonts.tajawal(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            'تظهر بداية جملة لكما، يكتب كل منكما إجابته سراً، وتنكشف الإجابات بعد انتهاء كليكما من الكتابة!',
            style: GoogleFonts.tajawal(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          GradientButton(
            text: 'ابدأ التحدي 🚀',
            onPressed: () async {
              final randomPrompt = _prompts[Random().nextInt(_prompts.length)];
              await ref.read(gameServiceProvider).startCompleteSentence(coupleId, randomPrompt, myId, partnerId);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameView(String coupleId, String myId, String partnerName, CompleteSentenceGameState game) {
    final isPlayer1 = myId == game.player1Id;
    final myAnswer = isPlayer1 ? game.player1Answer : game.player2Answer;
    final partnerAnswer = isPlayer1 ? game.player2Answer : game.player1Answer;

    final hasAnswered = myAnswer != null && myAnswer.isNotEmpty;
    final partnerHasAnswered = partnerAnswer != null && partnerAnswer.isNotEmpty;

    if (game.status == 'active') {
      if (hasAnswered) {
        return Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.hourglass_top_rounded, size: 64, color: Colors.amber),
            const SizedBox(height: 24),
            Text(
              'بانتظار إجابة شريكك $partnerName...',
              style: GoogleFonts.tajawal(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الجملة: ${game.prompt}', style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(myAnswer, style: GoogleFonts.tajawal(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'أكمل الجملة التالية سراً:',
              style: GoogleFonts.tajawal(fontSize: 16, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              game.prompt,
              style: GoogleFonts.tajawal(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _answerController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'اكتب إجابتك هنا...',
                hintStyle: GoogleFonts.tajawal(color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: 'أرسل الإجابة 🚀',
              onPressed: () async {
                final ans = _answerController.text.trim();
                if (ans.isEmpty) return;
                await ref.read(gameServiceProvider).submitSentenceAnswer(coupleId, ans, myId);
                _answerController.clear();
              },
            ),
          ],
        );
      }
    } else {
      // revealed
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('💖', style: TextStyle(fontSize: 50), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
            game.prompt,
            style: GoogleFonts.tajawal(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('إجابتك:', style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                Text(myAnswer ?? '', style: GoogleFonts.tajawal(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ).animate().slideX(begin: -0.1).fadeIn(),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.roseGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('إجابة $partnerName:', style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                Text(partnerAnswer ?? '', style: GoogleFonts.tajawal(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ).animate().slideX(begin: 0.1).fadeIn(),
          const SizedBox(height: 48),
          GradientButton(
            text: 'جملة أخرى 🔄',
            onPressed: () async {
              final randomPrompt = _prompts[Random().nextInt(_prompts.length)];
              await ref.read(gameServiceProvider).startCompleteSentence(coupleId, randomPrompt, myId, game.player2Id);
            },
          ),
        ],
      );
    }
  }
}
