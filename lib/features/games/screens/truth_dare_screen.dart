import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/games_provider.dart';

class TruthDareScreen extends ConsumerStatefulWidget {
  const TruthDareScreen({super.key});

  @override
  ConsumerState<TruthDareScreen> createState() => _TruthDareScreenState();
}

class _TruthDareScreenState extends ConsumerState<TruthDareScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  
  // Offline variables
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
  ];
  final List<String> _dares = [
    'اتصل بي الآن وقل لي كلمة حب',
    'أرسل لي رسالة صوتية تقول فيها "أحبك" بعشر طرق مختلفة',
    'اكتب لي قصيدة قصيرة الآن',
    'صف يومنا المثالي الذي تتمناه',
    'أخبرني بالشيء الذي خفتَ أن تقوله لي من قبل',
  ];

  // Online variables
  final TextEditingController _customChallengeController = TextEditingController();
  String _customType = 'truth'; // 'truth' or 'dare'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customChallengeController.dispose();
    super.dispose();
  }

  void _showOfflineCard(bool isTruth) {
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
        title: Text(
          'الحقيقة أو الجرأة 🎭',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'أسئلة التطبيق'),
            Tab(text: 'تحديات بيننا'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOfflineTab(),
          _buildOnlineTab(),
        ],
      ),
    );
  }

  // ── Offline mode UI ──
  Widget _buildOfflineTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
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
                        const Text('🎴', style: TextStyle(fontSize: 60)),
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
                          style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _currentCard!,
                          style: GoogleFonts.tajawal(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showOfflineCard(true),
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: AppColors.purpleGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text('حقيقة ❓', style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showOfflineCard(false),
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: AppColors.roseGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text('جرأة 🔥', style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Online mode UI ──
  Widget _buildOnlineTab() {
    final coupleId = ref.watch(coupleIdProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final partner = ref.watch(currentPartnerProvider).value;
    final gameAsync = ref.watch(truthDareGameStreamProvider);

    if (coupleId == null || currentUser == null || partner == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final game = gameAsync.value;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (game == null) ...[
            // Screen to send a challenge to the partner
            Text(
              'أرسل تحدياً مخصصاً لـ ${partner.name}',
              style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: Text('حقيقة ❓', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
                  selected: _customType == 'truth',
                  selectedColor: AppColors.primary.withOpacity(0.3),
                  onSelected: (val) {
                    if (val) setState(() => _customType = 'truth');
                  },
                ),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: Text('جرأة 🔥', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
                  selected: _customType == 'dare',
                  selectedColor: AppColors.secondary.withOpacity(0.3),
                  onSelected: (val) {
                    if (val) setState(() => _customType = 'dare');
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _customChallengeController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: _customType == 'truth' ? 'اكتب سؤال صراحة هنا...' : 'اكتب جرأة أو طلباً هنا...',
                hintStyle: GoogleFonts.tajawal(color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: 'أرسل التحدي الآن 💌',
              onPressed: () async {
                if (_customChallengeController.text.trim().isEmpty) return;
                await ref.read(gameServiceProvider).sendTruthDareChallenge(
                      coupleId,
                      currentUser.id,
                      partner.id,
                      _customChallengeController.text.trim(),
                      _customType,
                    );
                _customChallengeController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إرسال التحدي بنجاح!')),
                );
              },
            ),
          ] else if (game.status == 'pending') ...[
            if (game.creatorId == currentUser.id) ...[
              // I created it, waiting for partner
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    const Icon(Icons.hourglass_empty_rounded, size: 48, color: Colors.amber),
                    const SizedBox(height: 16),
                    Text(
                      'أرسلت تحدياً لـ ${partner.name}',
                      style: GoogleFonts.tajawal(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"${game.challengeText}"',
                      style: GoogleFonts.tajawal(fontSize: 14, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'بانتظار إتمام التحدي من شريكك...',
                      style: GoogleFonts.tajawal(fontSize: 12, color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Partner created it, I need to respond
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: game.challengeType == 'truth' ? AppColors.purpleGradient : AppColors.roseGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      game.challengeType == 'truth' ? '❓ تحدي صراحة من شريكك' : '🔥 جرأة من شريكك',
                      style: GoogleFonts.tajawal(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      game.challengeText,
                      style: GoogleFonts.tajawal(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    GradientButton(
                      text: 'تم الإنجاز! 🎉 (+10 نقاط)',
                      onPressed: () async {
                        await ref.read(gameServiceProvider).respondToTruthDareChallenge(coupleId, currentUser.id);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ] else if (game.status == 'completed') ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  const Icon(Icons.check_circle_rounded, size: 54, color: Colors.green),
                  const SizedBox(height: 16),
                  Text(
                    'اكتمل التحدي! 💖',
                    style: GoogleFonts.tajawal(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    text: 'تحدٍ جديد 🔄',
                    onPressed: () async {
                      await ref.read(gameServiceProvider).resetTruthDareGame(coupleId);
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
