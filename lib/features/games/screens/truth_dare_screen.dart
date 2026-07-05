import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';

class TruthDareScreen extends StatefulWidget {
  const TruthDareScreen({super.key});

  @override
  State<TruthDareScreen> createState() => _TruthDareScreenState();
}

class _TruthDareScreenState extends State<TruthDareScreen> {
  String? _currentCard;
  bool _isTruth = true;

  final List<String> _truths = [
    'ما أجمل ذكرى لك معي؟',
    'ما الشيء الذي تحبه فيّ أكثر؟',
    'متى أدركت أنك تحبني؟',
    'ما أكثر شيء يجعلك تضحك معي؟',
    'ما الشيء الذي تتمنى أن أفعله لك؟',
    'ما أكثر لحظة شعرت فيها بالفخر بي؟',
    'ما الشيء الذي تخشى أن يزعجني؟',
    'ما أحلامك التي تتمنى أن نحققها معاً؟',
    'ما الشيء الذي تتمنى لو عرفته عني مبكراً؟',
    'ما الكلمة التي تصف بها علاقتنا؟',
    'ما أكثر لحظة اشتقت فيها إليّ؟',
    'هل سبق أن خيّبت ظنك؟ كيف؟',
    'ما أكثر شيء تشكر الله عليه في علاقتنا؟',
    'ما الشيء الذي يجعلك تشعر بالأمان معي؟',
    'ما الأغنية التي تذكّرك بي؟',
  ];

  final List<String> _dares = [
    'اتصل بي الآن وقل لي كلمة حب',
    'أرسل لي رسالة صوتية تقول فيها "أحبك" بعشر طرق مختلفة',
    'اكتب لي قصيدة قصيرة الآن',
    'صف يومنا المثالي الذي تتمناه',
    'أخبرني بالشيء الذي خفتَ أن تقوله لي من قبل',
    'ارسم لي وجهاً يصف شعورك تجاهي',
    'غنِّ لي أغنية تحبها',
    'صوّر شيئاً يذكّرك بي وأرسله',
    'اكتب لي 10 أشياء تحبها فيّ',
    'اصنع لي شيئاً بيدك وأرسل لي صورته',
    'شارك معي لحظة محرجة من حياتك',
    'تعهّد بأمر جميل ستفعله لي هذا الأسبوع',
    'صِف ما تشعر به الآن في 3 كلمات فقط',
    'أخبرني بحلمك عن مستقبلنا',
    'ابتكر اسماً جديداً لي واشرح سببه',
  ];

  void _showCard(bool isTruth) {
    final list = isTruth ? _truths : _dares;
    setState(() {
      _isTruth = isTruth;
      _currentCard = list[Random().nextInt(list.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withOpacity(0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('الحقيقة أو الجرأة 🎭', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Card display
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(scale: anim, child: child),
              ),
              child: _currentCard == null
                  ? Container(
                      key: const ValueKey('empty'),
                      height: 240,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🎴', style: const TextStyle(fontSize: 60)),
                          const SizedBox(height: 16),
                          Text(
                            'اختر حقيقة أو جرأة',
                            style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      key: ValueKey(_currentCard),
                      height: 240,
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: _isTruth ? AppColors.purpleGradient : AppColors.roseGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: (_isTruth ? AppColors.primaryDark : AppColors.secondaryDark).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isTruth ? '❓ حقيقة' : '🔥 جرأة',
                            style: GoogleFonts.tajawal(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _currentCard!,
                            style: GoogleFonts.tajawal(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 48),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showCard(true),
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppColors.purpleGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: AppColors.primaryDark.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 6))],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('❓', style: const TextStyle(fontSize: 28)),
                          Text('حقيقة', style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ).animate().slideX(begin: -0.3).fadeIn(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showCard(false),
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppColors.roseGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: AppColors.secondaryDark.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 6))],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🔥', style: const TextStyle(fontSize: 28)),
                          Text('جرأة', style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ).animate().slideX(begin: 0.3).fadeIn(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            if (_currentCard != null)
              OutlinedButton.icon(
                onPressed: () => _showCard(_isTruth),
                icon: const Icon(Icons.shuffle_rounded),
                label: Text('سؤال آخر', style: GoogleFonts.tajawal(fontSize: 15)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ).animate().fadeIn(),
          ],
        ),
      ),
    );
  }
}
