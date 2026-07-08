import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../../games/providers/games_provider.dart';

class DailyChallengeWidget extends ConsumerWidget {
  const DailyChallengeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupleId = ref.watch(coupleIdProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final partner = ref.watch(currentPartnerProvider).value;
    final dateKey = ref.watch(dailyChallengeDateKeyProvider);
    final challengeAsync = ref.watch(dailyChallengeStreamProvider);

    if (coupleId == null || currentUser == null || partner == null) {
      return const SizedBox.shrink();
    }

    final challenge = challengeAsync.value;

    if (challenge == null) {
      // Auto-initialize daily challenge for the couple if null
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final List<Map<String, String>> pool = [
          {'type': 'text', 'text': '❤️ اكتب ثلاث صفات تحبها في شريكك الآن'},
          {'type': 'photo', 'text': '📷 التقط صورة لشيء يذكرك بشريكك'},
          {'type': 'voice', 'text': '🎤 أرسل رسالة صوتية تعبر فيها عن حبك له'},
          {'type': 'drawing', 'text': '🎨 ارسم قلباً لشريكك خلال دقيقة واحدة'},
          {'type': 'question', 'text': '❓ أجب عن سؤال تعارف جديد: ما هي أكلته المفضلة؟'},
        ];
        final picked = pool[DateTime.now().day % pool.length];
        await ref.read(gameServiceProvider).initializeDailyChallenge(
              coupleId,
              dateKey,
              picked['type']!,
              picked['text']!,
            );
      });
      return const SizedBox.shrink();
    }

    final myCompleted = challenge.userCompletions[currentUser.id] == true;
    final partnerCompleted = challenge.userCompletions[partner.id] == true;

    Color cardBorderColor = Colors.white.withOpacity(0.05);
    String statusLabel = 'تحدي اليوم المشترك 🌟';
    Widget actionWidget = const SizedBox.shrink();

    if (myCompleted && partnerCompleted) {
      cardBorderColor = Colors.green.withOpacity(0.3);
      statusLabel = 'تم الإنجاز بنجاح! (+20 نقطة) 🎉';
      actionWidget = Text(
        'أنجزتما التحدي اليوم بنجاح وربحتما النقاط!',
        style: GoogleFonts.tajawal(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold),
      );
    } else if (myCompleted) {
      cardBorderColor = Colors.amber.withOpacity(0.3);
      statusLabel = 'أنجزت دورك! بانتظار شريكك... ⏳';
      actionWidget = Text(
        'بانتظار أن يكمل ${partner.name} تحدي اليوم.',
        style: GoogleFonts.tajawal(color: Colors.amber, fontSize: 13),
      );
    } else {
      actionWidget = GradientButton(
        text: 'أنجز التحدي الآن 🚀',
        onPressed: () {
          _showSubmissionDialog(context, ref, coupleId, dateKey, currentUser.id, partner.id, challenge.challengeText);
        },
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                statusLabel,
                style: GoogleFonts.tajawal(
                  color: myCompleted && partnerCompleted ? Colors.green : AppColors.secondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            challenge.challengeText,
            style: GoogleFonts.tajawal(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          actionWidget,
        ],
      ),
    );
  }

  void _showSubmissionDialog(
    BuildContext context,
    WidgetRef ref,
    String coupleId,
    String dateKey,
    String myId,
    String partnerId,
    String challengeText,
  ) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'تحدي اليوم 🌟',
            style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(challengeText, style: GoogleFonts.tajawal(color: Colors.white70)),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'اكتب إجابتك هنا...',
                  hintStyle: GoogleFonts.tajawal(color: AppColors.textHint),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء', style: GoogleFonts.tajawal(color: AppColors.textHint)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final text = textController.text.trim();
                if (text.isEmpty) return;
                await ref.read(gameServiceProvider).submitDailyChallenge(coupleId, dateKey, myId, partnerId, text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تسجيل إتمام التحدي بنجاح!')),
                  );
                }
              },
              child: Text('تسليم', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
