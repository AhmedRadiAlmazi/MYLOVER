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

class VoiceChallengeScreen extends ConsumerStatefulWidget {
  const VoiceChallengeScreen({super.key});

  @override
  ConsumerState<VoiceChallengeScreen> createState() => _VoiceChallengeScreenState();
}

class _VoiceChallengeScreenState extends ConsumerState<VoiceChallengeScreen> {
  bool _isRecording = false;
  int _seconds = 0;
  bool _hasRecorded = false;
  double _rating = 0.0;

  final List<String> _phrases = [
    'أحبك بأجمل صوت لديك ❤️',
    'أشتاق إليك في كل ثانية 🥺',
    'أنت أجمل ما حدث لي في حياتي ✨',
    'صباح الخير يا نبض قلبي ☀️',
    'دمت لي سنداً وحبيباً وروحاً 💕',
  ];

  void _startTimer() async {
    while (_isRecording) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_isRecording) break;
      setState(() {
        _seconds++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final coupleId = ref.watch(coupleIdProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final partner = ref.watch(currentPartnerProvider).value;
    final gameAsync = ref.watch(voiceChallengeGameStreamProvider);

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
          'تحدي الصوت 🎤',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: game == null
            ? _buildSetupView(coupleId, currentUser.id, partner.id, partner.name)
            : _buildActiveChallengeView(coupleId, currentUser.id, partner.name, game),
      ),
    );
  }

  Widget _buildSetupView(String coupleId, String myId, String partnerId, String partnerName) {
    final phrase = _phrases[DateTime.now().second % _phrases.length];
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          Text(
            'قل لشريكك بصوتك:',
            style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Text(
            '" $phrase "',
            style: GoogleFonts.tajawal(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          GestureDetector(
            onTap: () {
              if (!_isRecording && !_hasRecorded) {
                setState(() {
                  _isRecording = true;
                  _seconds = 0;
                });
                _startTimer();
              } else if (_isRecording) {
                setState(() {
                  _isRecording = false;
                  _hasRecorded = true;
                });
              }
            },
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _isRecording ? AppColors.roseGradient : AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: (_isRecording ? AppColors.secondary : AppColors.primary).withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: _isRecording ? 10 : 0,
                  )
                ],
              ),
              child: Icon(
                _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                size: 54,
                color: Colors.white,
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                  begin: const Offset(1.0, 1.0),
                  end: Offset(_isRecording ? 1.15 : 1.0, _isRecording ? 1.15 : 1.0),
                  duration: 600.ms,
                ),
          ),
          const SizedBox(height: 24),
          Text(
            _isRecording
                ? 'جاري التسجيل: $_seconds ثانية...'
                : (_hasRecorded ? 'تم التسجيل بنجاح!' : 'اضغط للبدء بالتسجيل'),
            style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 48),
          if (_hasRecorded)
            GradientButton(
              text: 'أرسل التسجيل لـ $partnerName 🚀',
              onPressed: () async {
                // Simulate audio URL link upload
                await ref.read(gameServiceProvider).startVoiceChallenge(
                      coupleId,
                      myId,
                      partnerId,
                      phrase,
                      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3', // sweet placeholder audio
                    );
                setState(() {
                  _hasRecorded = false;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActiveChallengeView(String coupleId, String myId, String partnerName, VoiceChallengeGameState game) {
    final isSender = game.senderId == myId;

    if (game.status == 'recorded') {
      if (isSender) {
        return Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.check_circle_rounded, size: 72, color: Colors.green),
            const SizedBox(height: 24),
            Text(
              'تم إرسال التسجيل الصوتي بنجاح! 💖',
              style: GoogleFonts.tajawal(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'بانتظار تقييم شريكك لجمال صوتك...',
              style: GoogleFonts.tajawal(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        );
      } else {
        // Rater page
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'استمع إلى تسجيل $partnerName:',
              style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '" ${game.phrase} "',
              style: GoogleFonts.tajawal(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            // Simulated audio player
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow_rounded, size: 36, color: AppColors.primary),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('جاري تشغيل الصوت... 🎵')),
                      );
                    },
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: LinearProgressIndicator(value: 0.4, color: AppColors.primary, backgroundColor: AppColors.divider),
                    ),
                  ),
                  Text('0:12', style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Text(
              'كم تقيم جمال صوته؟ ⭐️',
              style: GoogleFonts.tajawal(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1.0;
                return IconButton(
                  icon: Icon(
                    starValue <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 40,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = starValue;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 32),
            GradientButton(
              text: 'إرسال التقييم ⭐',
              onPressed: () {
                if (_rating == 0.0) return;
                ref.read(gameServiceProvider)
                    .rateVoiceChallenge(coupleId, _rating, myId)
                    .then((_) {
                  setState(() {
                    _rating = 0.0;
                  });
                });
              },
            ),
          ],
        );
      }
    } else {
      // rated
      return Column(
        children: [
          const Icon(Icons.star_rounded, size: 72, color: Colors.amber),
          const SizedBox(height: 24),
          Text(
            isSender ? 'تم تقييم صوتك من قبل شريكك!' : 'شكراً لتقييمك شريكك!',
            style: GoogleFonts.tajawal(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'حصلت على ${game.rating} نجوم 🌟',
            style: GoogleFonts.tajawal(fontSize: 20, color: AppColors.secondary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 48),
          GradientButton(
            text: 'تحدٍ جديد 🔄',
            onPressed: () async {
              // Delete voice challenge state to trigger new session
              await ref.read(gameServiceProvider).resetTruthDareGame(coupleId); // generic reset
              await ref.read(gameServiceProvider).startVoiceChallenge(coupleId, 'reset', 'reset', '', '');
            },
          ),
        ],
      );
    }
  }
}
