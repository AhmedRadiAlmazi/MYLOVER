import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../memories/providers/memories_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/games_provider.dart';

class GuessPictureScreen extends ConsumerStatefulWidget {
  const GuessPictureScreen({super.key});

  @override
  ConsumerState<GuessPictureScreen> createState() => _GuessPictureScreenState();
}

class _GuessPictureScreenState extends ConsumerState<GuessPictureScreen> {
  dynamic _selectedMemory;
  List<String> _choices = [];
  int _correctIndex = 0;
  double _blurSigma = 30.0;
  int _secondsElapsed = 0;
  Timer? _timer;
  int? _selectedChoiceIndex;
  bool _answered = false;

  void _startQuiz(List<dynamic> memories) {
    final valid = memories.where((m) => m.mediaUrl != null && m.mediaUrl!.isNotEmpty).toList();
    if (valid.isEmpty) return;

    final correctMem = valid[Random().nextInt(valid.length)];
    final opts = [correctMem.title, 'رحلة الصيف', 'لقاء المقهى', 'عشاء رومانسي', 'يوم المطر', 'عيد ميلاد سعيد']
        .cast<String>()
        .toSet()
        .toList()
        .take(4)
        .toList();
    opts.shuffle();
    final correctIdx = opts.indexOf(correctMem.title as String);

    setState(() {
      _selectedMemory = correctMem;
      _choices = opts;
      _correctIndex = correctIdx;
      _blurSigma = 30.0;
      _secondsElapsed = 0;
      _selectedChoiceIndex = null;
      _answered = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _secondsElapsed++;
        if (_blurSigma > 0) {
          _blurSigma = max(0, 30.0 - (_secondsElapsed / 3) * 10.0);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coupleId = ref.watch(coupleIdProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final memoriesAsync = ref.watch(memoriesStreamProvider);

    if (coupleId == null || currentUser == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final memories = memoriesAsync.value ?? [];

    if (_selectedMemory == null && memories.isNotEmpty) {
      // Delay initialization
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedMemory == null) {
          _startQuiz(memories);
        }
      });
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
        title: Text(
          'خمن الصورة 🖼️',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: memories.isEmpty
            ? _buildNoMemoriesView()
            : (_selectedMemory == null
                ? const Center(child: CircularProgressIndicator())
                : _buildGamePlayView(coupleId, currentUser.id, memories)),
      ),
    );
  }

  Widget _buildNoMemoriesView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          const Text('🖼️', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(
            'لا توجد صور كافية!',
            style: GoogleFonts.tajawal(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'يرجى إضافة ذكريات تحتوي على صور للعب هذه اللعبة.',
            style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGamePlayView(String coupleId, String myId, List<dynamic> memories) {
    final String imgUrl = _selectedMemory.mediaUrl!;
    final isCorrect = _selectedChoiceIndex == _correctIndex;

    // Calculate score based on speed
    int pointsAwarded = 5;
    if (_secondsElapsed < 4) {
      pointsAwarded = 20;
    } else if (_secondsElapsed < 8) {
      pointsAwarded = 15;
    } else if (_secondsElapsed < 12) {
      pointsAwarded = 10;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image with Blur
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 220,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(imgUrl, fit: BoxFit.cover),
                if (_blurSigma > 0 && !_answered)
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
                    child: Container(color: Colors.black.withOpacity(0.1)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _answered ? 'الكلمة الصحيحة هي: ${_selectedMemory.title}' : 'ما عنوان هذه الصورة؟ (التمويه يقل مع الوقت)',
          style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ...List.generate(_choices.length, (i) {
          final isSelected = _selectedChoiceIndex == i;
          final isCorrectChoice = _correctIndex == i;

          Color cardColor = AppColors.card;
          if (_answered) {
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
              onTap: _answered
                  ? null
                  : () async {
                      _timer?.cancel();
                      setState(() {
                        _selectedChoiceIndex = i;
                        _answered = true;
                      });
                      if (i == _correctIndex) {
                        await ref.read(gameServiceProvider).addPointsAndStats(myId, pointsAwarded, winField: 'whoKnowsWins');
                      }
                    },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.05)),
                ),
                child: Text(
                  _choices[i],
                  style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
        if (_answered) ...[
          Text(
            isCorrect ? 'رائع! خمنتها بشكل صحيح وسريع! (+$pointsAwarded نقطة) 🎉' : 'حظاً موفقاً المرة القادمة! 🥺',
            style: GoogleFonts.tajawal(
              fontSize: 15,
              color: isCorrect ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GradientButton(
            text: 'صورة أخرى 🔄',
            onPressed: () => _startQuiz(memories),
          ),
        ],
      ],
    );
  }
}
