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

class WheelScreen extends ConsumerStatefulWidget {
  const WheelScreen({super.key});

  @override
  ConsumerState<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends ConsumerState<WheelScreen> with TickerProviderStateMixin {
  late final AnimationController _spinController;
  double _angle = 0.0;
  bool _isSpinning = false;
  String? _resultText;

  final List<String> _tasks = [
    '❤️ أرسل رسالة حب الآن',
    '📷 التقط صورة سيلفي لطيفة',
    '🎁 أنشئ مفاجأة جديدة لشريكك',
    '🎤 أرسل بصمة صوتية تعبر فيها عن حبك',
    '🎨 ارسم قلبًا وأرسله فوراً',
    '🌟 أخبر شريكك بـ 3 أشياء تحبها فيه',
    '💍 اطلب موعداً رومانسياً قادماً',
    '✨ تعهد بفعل شيء يسعد شريكك الليلة',
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _spin(String coupleId, String myId) {
    if (_isSpinning) return;
    setState(() {
      _isSpinning = true;
      _resultText = null;
    });

    final randomTarget = Random().nextDouble() * 2 * pi + (6 * pi); // spin 3 times + random offset
    final targetSegmentIndex = ((randomTarget % (2 * pi)) / (2 * pi) * _tasks.length).floor();
    final selectedTask = _tasks[_tasks.length - 1 - targetSegmentIndex];

    _spinController.forward(from: 0.0).then((_) async {
      setState(() {
        _angle = randomTarget;
        _isSpinning = false;
        _resultText = selectedTask;
      });

      await ref.read(gameServiceProvider).spinWheel(coupleId, myId, selectedTask);
    });

    // Animate rotation value
    _spinController.addListener(() {
      setState(() {
        _angle = _spinController.value * randomTarget;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final coupleId = ref.watch(coupleIdProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final partner = ref.watch(currentPartnerProvider).value;
    final gameAsync = ref.watch(wheelGameStreamProvider);

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
          'عجلة المفاجآت 🎡',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // The wheel container
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer border glow
                  Container(
                    width: 270,
                    height: 270,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 25,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  // Rotating Wheel Artwork
                  Transform.rotate(
                    angle: _angle,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage('https://i.ibb.co/L5hY99q/wheel-art.jpg'), // Placeholder fallback wheel graphic
                          fit: BoxFit.cover,
                          onError: _handleImageError,
                        ),
                        color: AppColors.card,
                      ),
                      child: CustomPaint(
                        painter: WheelSegmentsPainter(segmentsCount: _tasks.length),
                        size: const Size(260, 260),
                      ),
                    ),
                  ),
                  // Indicator Pointer
                  Positioned(
                    top: 0,
                    child: Container(
                      width: 20,
                      height: 35,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  // Center Pin
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 6)],
                    ),
                    child: const Icon(Icons.favorite, color: Colors.red, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Spin buttons / Result view
            if (game == null || game.status == 'done') ...[
              GradientButton(
                text: 'أدر العجلة الآن 🎡',
                onPressed: () {
                  if (!_isSpinning) {
                    _spin(coupleId, currentUser.id);
                  }
                },
              ),
            ] else ...[
              // Active request
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.purpleGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text(
                      'المفاجأة المنتظرة:',
                      style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      game.taskText,
                      style: GoogleFonts.tajawal(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    if (game.spinnerId == currentUser.id)
                      GradientButton(
                        text: 'أكملت التحدي بنجاح! (+5 نقاط) 🎉',
                        onPressed: () async {
                          await ref.read(gameServiceProvider).completeWheelTask(coupleId, currentUser.id);
                        },
                      )
                    else
                      Text(
                        'بانتظار إتمام التحدي من شريكك...',
                        style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 13),
                      ),
                  ],
                ),
              ).animate().scale(),
            ],
          ],
        ),
      ),
    );
  }

  static void _handleImageError(Object exception, StackTrace? stackTrace) {}
}

class WheelSegmentsPainter extends CustomPainter {
  final int segmentsCount;
  WheelSegmentsPainter({required this.segmentsCount});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final sweepAngle = 2 * pi / segmentsCount;
    final List<Color> segmentColors = [
      const Color(0xFFE5447A),
      const Color(0xFF8B3FD9),
      const Color(0xFF1565C0),
      const Color(0xFF2D6A4F),
      const Color(0xFFD4A017),
      const Color(0xFFBF360C),
      const Color(0xFF004D40),
      const Color(0xFF6A1B9A),
    ];

    for (int i = 0; i < segmentsCount; i++) {
      final paint = Paint()
        ..color = segmentColors[i % segmentColors.length].withOpacity(0.85)
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, i * sweepAngle, sweepAngle, true, paint);

      // Segment separator lines
      final linePaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..strokeWidth = 2.0;
      final x = center.dx + radius * cos(i * sweepAngle);
      final y = center.dy + radius * sin(i * sweepAngle);
      canvas.drawLine(center, Offset(x, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
