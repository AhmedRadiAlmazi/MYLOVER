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

class WhoKnowsScreen extends ConsumerStatefulWidget {
  const WhoKnowsScreen({super.key});

  @override
  ConsumerState<WhoKnowsScreen> createState() => _WhoKnowsScreenState();
}

class _WhoKnowsScreenState extends ConsumerState<WhoKnowsScreen> {
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = List.generate(4, (_) => TextEditingController());
  int _correctIndex = 0;

  @override
  void dispose() {
    _questionController.dispose();
    for (var c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coupleId = ref.watch(coupleIdProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final partner = ref.watch(currentPartnerProvider).value;
    final gameAsync = ref.watch(whoKnowsGameStreamProvider);

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
          'من يعرف الآخر أكثر؟ ❤️',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: game == null
            ? _buildQuestionCreationForm(coupleId, currentUser.id, partner.id, partner.name)
            : _buildGameStatusView(coupleId, currentUser.id, partner.name, game),
      ),
    );
  }

  Widget _buildQuestionCreationForm(String coupleId, String myId, String partnerId, String partnerName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'أنشئ سؤالاً لـ $partnerName',
          style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _questionController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'السؤال (مثال: ما هو لوني المفضل؟)',
            labelStyle: GoogleFonts.tajawal(color: AppColors.textHint),
            filled: true,
            fillColor: AppColors.card,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 20),
        ...List.generate(4, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Radio<int>(
                  value: i,
                  groupValue: _correctIndex,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val != null) setState(() => _correctIndex = val);
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _optionControllers[i],
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'الخيار ${i + 1}',
                      hintStyle: GoogleFonts.tajawal(color: AppColors.textHint),
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        Text(
          '* حدد الدائرة بجانب الخيار الصحيح قبل الإرسال',
          style: GoogleFonts.tajawal(color: AppColors.textHint, fontSize: 11),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        GradientButton(
          text: 'أرسل التحدي لـ $partnerName 🚀',
          onPressed: () async {
            final q = _questionController.text.trim();
            final opts = _optionControllers.map((o) => o.text.trim()).toList();
            if (q.isEmpty || opts.any((o) => o.isEmpty)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('الرجاء كتابة السؤال وملء كافة الخيارات!')),
              );
              return;
            }
            await ref.read(gameServiceProvider).createWhoKnowsQuestion(
                  coupleId,
                  myId,
                  partnerId,
                  q,
                  opts,
                  _correctIndex,
                );
            _questionController.clear();
            for (var c in _optionControllers) {
              c.clear();
            }
          },
        ),
      ],
    );
  }

  Widget _buildGameStatusView(String coupleId, String myId, String partnerName, WhoKnowsGameState game) {
    final isCreator = game.creatorId == myId;

    if (game.status == 'pending') {
      if (isCreator) {
        return Column(
          children: [
            const Icon(Icons.hourglass_bottom_rounded, size: 64, color: Colors.amber),
            const SizedBox(height: 24),
            Text(
              'بانتظار إجابة $partnerName...',
              style: GoogleFonts.tajawal(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'سؤالك المرسل:',
              style: GoogleFonts.tajawal(fontSize: 13, color: AppColors.textHint),
            ),
            const SizedBox(height: 8),
            Text(
              game.questionText,
              style: GoogleFonts.tajawal(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'تحدي من $partnerName 🧠',
              style: GoogleFonts.tajawal(fontSize: 18, color: AppColors.primary, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              game.questionText,
              style: GoogleFonts.tajawal(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ...List.generate(game.options.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () async {
                    await ref.read(gameServiceProvider).answerWhoKnowsQuestion(coupleId, i, myId);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Text(
                      game.options[i],
                      style: GoogleFonts.tajawal(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      }
    } else {
      // answered
      final isCorrect = game.selectedOptionIndex == game.correctOptionIndex;
      final selectedOpt = game.selectedOptionIndex != null ? game.options[game.selectedOptionIndex!] : '';
      final correctOpt = game.options[game.correctOptionIndex];

      return Column(
        children: [
          Icon(
            isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 72,
            color: isCorrect ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 24),
          Text(
            isCorrect
                ? (isCreator ? 'أجاب شريكك بشكل صحيح! 🎉' : 'إجابة صحيحة! (+10 نقاط) 🎉')
                : (isCreator ? 'أخطأ شريكك في الإجابة! 🥺' : 'إجابة خاطئة! 🥺'),
            style: GoogleFonts.tajawal(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('السؤال: ${game.questionText}', style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('الإجابة المختارة: $selectedOpt', style: GoogleFonts.tajawal(color: isCorrect ? Colors.green : Colors.red)),
                if (!isCorrect) ...[
                  const SizedBox(height: 6),
                  Text('الإجابة الصحيحة: $correctOpt', style: GoogleFonts.tajawal(color: Colors.green)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 48),
          GradientButton(
            text: 'تحدٍ جديد 🔄',
            onPressed: () async {
              await ref.read(gameServiceProvider).resetWhoKnowsGame(coupleId);
            },
          ),
        ],
      );
    }
  }
}
