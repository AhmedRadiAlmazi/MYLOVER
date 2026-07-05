import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final _inputController = TextEditingController();
  String? _response;
  bool _isLoading = false;

  final List<_AIAction> _actions = [
    _AIAction(emoji: '💌', title: 'اكتب رسالة حب', prompt: 'رسالة حب'),
    _AIAction(emoji: '💑', title: 'أفكار للمواعيد', prompt: 'أفكار مواعيد'),
    _AIAction(emoji: '🎁', title: 'اقتراح هدايا', prompt: 'اقتراح هدايا'),
    _AIAction(emoji: '📝', title: 'إنشاء قصيدة', prompt: 'قصيدة حب'),
    _AIAction(emoji: '🎉', title: 'بطاقة تهنئة', prompt: 'بطاقة تهنئة'),
    _AIAction(emoji: '😄', title: 'نكتة رومانسية', prompt: 'نكتة رومانسية'),
  ];

  final Map<String, String> _mockResponses = {
    'رسالة حب': 'حبيبي/حبيبتي،\n\nكل يوم أصبح أكثر يقيناً أن الله أرسلك لي هدية لا تُقدَّر. في عينيك أرى منزلي، وفي ابتسامتك أجد سلامي. أحبك ليس فقط لأنك جميل/جميلة من الخارج، بل لأن روحك تضيء حياتي.\n\nلك كل قلبي ❤️',
    'أفكار مواعيد': '🌹 أفكار رومانسية:\n\n1. نزهة ليلية تحت النجوم\n2. طبخ عشاء معاً في المنزل\n3. مشاهدة فيلم مع الفشار والبطانية\n4. جولة في سوق قديم\n5. لعب ألعاب لوحية ومراهنات ممتعة\n6. زيارة متحف أو معرض فني',
    'اقتراح هدايا': '🎁 هدايا مميزة:\n\n• كتاب قصصنا (ذكريات مُجمَّعة)\n• إكسسوار فضي باسم شريكك\n• رحلة مفاجأة لمكان يحبه\n• صندوق هدايا شخصية صغيرة\n• تجربة فريدة (مطعم خاص، سبا...)\n• إطار صور بأجمل لحظاتكما',
    'قصيدة حب': 'في عينيكِ عالمٌ لا ينتهي،\nوفي حضنكِ أجدُ من أكون.\nأنتِ الفصولُ كلّها ومرعاها،\nأنتِ السكونُ وأنتِ الحنين.\n\nأحبّكِ حين يغيبُ الصبحُ والمساء،\nوحين تغفو النجومُ خلف السحاب.\nأنتِ القصيدةُ لم تكتمل بعدُ،\nوأنا القلمُ في يدِكِ والكتاب.',
    'بطاقة تهنئة': '🎉 عيد ميلادك السعيد!\n\nيا أجمل هدية في حياتي،\nكل عام وأنت تملأ دنيتي بهجةً وضياءً.\nأتمنى لك عاماً مليئاً بكل ما يُسعدك،\nوأن تبقى دائماً المعنى الأجمل لحياتي.\n\nأحبك إلى ما لا نهاية ❤️',
    'نكتة رومانسية': '😄 نكتة رومانسية:\n\nسألت الزهرة القمر: "لماذا تضيء الليل؟"\nقال القمر: "لأن هناك من يحب قراءة رسائل حبيبته في الظلام"\n\nوسألت الشمس الريح: "لماذا تهبّين في الربيع؟"\nقالت الريح: "لأحمل قُبَل العشاق بين المسافات" 🌸',
  };

  void _getResponse(String prompt) async {
    setState(() {
      _isLoading = true;
      _response = null;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _response = _mockResponses[prompt] ?? 'قريباً سيتوفر الذكاء الاصطناعي الكامل لمساعدتكما 🤖✨';
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
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
        title: Text('المساعد الذكي 🤖', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppColors.primaryDark.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 6))],
              ),
              child: Row(
                children: [
                  Text('🤖', style: const TextStyle(fontSize: 48)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('كيف يمكنني مساعدتكما؟', style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('اختر من الأدوات أو اكتب طلبك', style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().scale().fadeIn(),

            const SizedBox(height: 24),

            Text('الأدوات المتاحة', style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)).animate().fadeIn(),
            const SizedBox(height: 12),

            // Quick actions grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: _actions.length,
              itemBuilder: (context, i) {
                final action = _actions[i];
                return GestureDetector(
                  onTap: () => _getResponse(action.prompt),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(action.emoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 8),
                        Text(
                          action.title,
                          style: GoogleFonts.tajawal(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ).animate().scale(delay: Duration(milliseconds: i * 60)).fadeIn(delay: Duration(milliseconds: i * 60));
              },
            ),

            const SizedBox(height: 24),

            // Response area
            if (_isLoading)
              const Center(child: LoadingWidget(message: 'جارٍ التفكير...'))
            else if (_response != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Text('الرد:', style: GoogleFonts.tajawal(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _response!,
                      style: GoogleFonts.tajawal(color: AppColors.textPrimary, fontSize: 14, height: 1.7),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          label: Text('نسخ', style: GoogleFonts.tajawal(fontSize: 13)),
                          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.share_rounded, size: 16),
                          label: Text('مشاركة', style: GoogleFonts.tajawal(fontSize: 13)),
                          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.3).fadeIn(),

            const SizedBox(height: 24),

            // Custom input
            Text('أو اكتب طلبك الخاص', style: GoogleFonts.tajawal(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    style: GoogleFonts.tajawal(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'اكتب ما تريد...',
                      hintStyle: GoogleFonts.tajawal(color: AppColors.textHint),
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: () {
                      if (_inputController.text.isNotEmpty) {
                        _getResponse(_inputController.text);
                        _inputController.clear();
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _AIAction {
  final String emoji;
  final String title;
  final String prompt;
  _AIAction({required this.emoji, required this.title, required this.prompt});
}
