import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_universe/features/games/models/game_models.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../memories/providers/memories_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/games_provider.dart';

class MemoriesQuizScreen extends ConsumerStatefulWidget {
  const MemoriesQuizScreen({super.key});

  @override
  ConsumerState<MemoriesQuizScreen> createState() => _MemoriesQuizScreenState();
}

class _MemoriesQuizScreenState extends ConsumerState<MemoriesQuizScreen> {
  int? _selectedIndex;
  bool _answered = false;

  @override
  Widget build(BuildContext context) {
    final coupleId = ref.watch(coupleIdProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final memoriesAsync = ref.watch(memoriesStreamProvider);
    final quizAsync = ref.watch(memoryQuizGameStreamProvider);

    if (coupleId == null || currentUser == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final memories = memoriesAsync.value ?? [];
    final quiz = quizAsync.value;

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
          'لعبة ذكرياتنا 📸',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: memories.isEmpty
            ? _buildNoMemoriesView()
            : (quiz == null
                ? _buildSetupQuizView(coupleId, memories)
                : _buildActiveQuizView(coupleId, quiz, memories, currentUser.id)),
      ),
    );
  }

  Widget _buildNoMemoriesView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          const Text('📸', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(
            'لا يوجد ذكريات كافية بعد!',
            style: GoogleFonts.tajawal(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'أضيفوا صوراً وذكريات في قسم الذكريات أولاً لتفعيل اللعبة.',
            style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSetupViewText(String label) {
    return Text(label, style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 15));
  }

  Widget _buildSetupQuizView(String coupleId, List<dynamic> memories) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildSetupViewText('اضغط لتوليد سؤال جديد من ذكرياتكما المشتركة!'),
          const SizedBox(height: 32),
          GradientButton(
            text: 'توليد سؤال 🪄',
            onPressed: () {
              // Pick random memory
              final validMemories = memories.where((m) => m.location != null && m.location!.isNotEmpty).toList();
              if (validMemories.isEmpty) {
                // fallback to date questions
                final randomMem = memories[Random().nextInt(memories.length)];
                final monthStr = DateFormat('MMMM', 'ar').format(randomMem.date);
                final choices = [monthStr, 'يناير', 'يوليو', 'سبتمبر', 'ديسمبر']
                    .toSet()
                    .cast<String>()
                    .toList();
                choices.shuffle();
                final selectedChoices = choices.take(4).toList();
                final correctIdx = selectedChoices.indexOf(monthStr);

                ref.read(gameServiceProvider).createMemoryQuiz(
                      coupleId,
                      randomMem.id,
                      'في أي شهر التقطنا صورة "${randomMem.title}"؟',
                      selectedChoices,
                      correctIdx,
                    );
              } else {
                final randomMem = validMemories[Random().nextInt(validMemories.length)];
                final location = randomMem.location! as String;
                final choices = [location, 'المنزل', 'الحديقة', 'المطعم', 'الشاطئ', 'دبي']
                    .toSet()
                    .cast<String>()
                    .toList();
                choices.shuffle();
                final selectedChoices = choices.take(4).toList();
                final correctIdx = selectedChoices.indexOf(location);

                ref.read(gameServiceProvider).createMemoryQuiz(
                      coupleId,
                      randomMem.id,
                      'أين كنا في هذه الذكرى: "${randomMem.title}"؟',
                      selectedChoices,
                      correctIdx,
                    );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActiveQuizView(String coupleId, MemoryQuizGameState quiz, List<dynamic> memories, String myId) {
    final relatedMem = memories.firstWhere((m) => m.id == quiz.memoryId, orElse: () => null);
    final String? imgUrl = relatedMem?.mediaUrl;

    final quizAnswered = quiz.status == 'answered' || _answered;
    final isCorrect = (quiz.selectedChoiceIndex ?? _selectedIndex) == quiz.correctChoiceIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (imgUrl != null && imgUrl.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              imgUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 24),
        ],
        Text(
          quiz.question,
          style: GoogleFonts.tajawal(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ...List.generate(quiz.choices.length, (i) {
          final isSelected = (quiz.selectedChoiceIndex ?? _selectedIndex) == i;
          final isCorrectChoice = quiz.correctChoiceIndex == i;

          Color cardColor = AppColors.card;
          if (quizAnswered) {
            if (isCorrectChoice) {
              cardColor = Colors.green.withOpacity(0.3);
            } else if (isSelected) {
              cardColor = Colors.red.withOpacity(0.3);
            }
          } else if (isSelected) {
            cardColor = AppColors.primary.withOpacity(0.3);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: quizAnswered
                  ? null
                  : () {
                      setState(() {
                        _selectedIndex = i;
                      });
                    },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.05),
                  ),
                ),
                child: Text(
                  quiz.choices[i],
                  style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
        if (!quizAnswered)
          GradientButton(
            text: 'تأكيد الإجابة 🚀',
            onPressed: () {
              if (_selectedIndex == null) return;
              setState(() {
                _answered = true;
              });
              ref.read(gameServiceProvider).answerMemoryQuiz(coupleId, _selectedIndex!, myId);
            },
          )
        else ...[
          Text(
            isCorrect ? 'إجابة صحيحة! (+15 نقطة) 🎉' : 'إجابة خاطئة! 🥺',
            style: GoogleFonts.tajawal(fontSize: 18, color: isCorrect ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GradientButton(
            text: 'سؤال آخر 🔄',
            onPressed: () {
              setState(() {
                _selectedIndex = null;
                _answered = false;
              });
              // Reset quiz state
              ref.read(gameServiceProvider).resetWhoKnowsGame(coupleId); // generics reset
            },
          ),
        ],
      ],
    );
  }
}
