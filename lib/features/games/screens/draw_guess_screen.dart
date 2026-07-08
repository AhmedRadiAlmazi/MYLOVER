import 'dart:convert';
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

class DrawingPoint {
  final double x;
  final double y;
  final bool isStart; // true if pointer down, false if line to

  DrawingPoint({required this.x, required this.y, required this.isStart});

  String serialize() => '$x,$y,${isStart ? 1 : 0}';

  factory DrawingPoint.deserialize(String s) {
    final parts = s.split(',');
    return DrawingPoint(
      x: double.tryParse(parts[0]) ?? 0,
      y: double.tryParse(parts[1]) ?? 0,
      isStart: parts[2] == '1',
    );
  }
}

class DrawGuessScreen extends ConsumerStatefulWidget {
  const DrawGuessScreen({super.key});

  @override
  ConsumerState<DrawGuessScreen> createState() => _DrawGuessScreenState();
}

class _DrawGuessScreenState extends ConsumerState<DrawGuessScreen> {
  final TextEditingController _guessController = TextEditingController();
  final List<DrawingPoint> _localPoints = [];
  bool _isPainter = true;
  DateTime _lastUploadTime = DateTime.now();

  @override
  void dispose() {
    _guessController.dispose();
    super.dispose();
  }

  void _syncDrawing(String coupleId) async {
    // Throttled drawing updates to prevent Firestore overload
    final now = DateTime.now();
    if (now.difference(_lastUploadTime).inMilliseconds > 300) {
      _lastUploadTime = now;
      final serialized = _localPoints.map((p) => p.serialize()).join(';');
      await ref.read(gameServiceProvider).updateDrawing(coupleId, serialized);
    }
  }

  void _finalizeDrawing(String coupleId) async {
    final serialized = _localPoints.map((p) => p.serialize()).join(';');
    await ref.read(gameServiceProvider).updateDrawing(coupleId, serialized);
  }

  @override
  Widget build(BuildContext context) {
    final coupleId = ref.watch(coupleIdProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final partner = ref.watch(currentPartnerProvider).value;
    final gameAsync = ref.watch(drawGuessGameStreamProvider);

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
          'ارسم وخمن 🎨',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: game == null
            ? _buildSetupView(coupleId, currentUser.id, partner.id, partner.name)
            : _buildActiveGameView(coupleId, currentUser.id, partner.name, game),
      ),
    );
  }

  Widget _buildSetupView(String coupleId, String myId, String partnerId, String partnerName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Text('🎨', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 24),
          Text(
            'ارسم وخمن',
            style: GoogleFonts.tajawal(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            'اختر دورك للبدء بالتحدي مع شريكك!',
            style: GoogleFonts.tajawal(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          GradientButton(
            text: 'أنا الرسام ✏️',
            onPressed: () async {
              setState(() {
                _isPainter = true;
                _localPoints.clear();
              });
              final words = ['قلب', 'وردة', 'شمس', 'بيت', 'شجرة', 'سيارة', 'نجمة', 'قمر', 'بحر'];
              final secret = words[DateTime.now().millisecond % words.length];
              await ref.read(gameServiceProvider).startDrawGuess(coupleId, myId, partnerId, secret);
            },
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            ),
            onPressed: () {
              setState(() {
                _isPainter = false;
              });
              // Just wait for stream to load
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('بانتظار بدء الرسم من قبل $partnerName...')),
              );
            },
            child: Text('أنا المخمن 👀', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveGameView(String coupleId, String myId, String partnerName, DrawGuessGameState game) {
    final painterMode = game.painterId == myId;

    if (game.status == 'painting') {
      if (painterMode) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'ارسم الكلمة التالية:',
              style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              game.secretWord,
              style: GoogleFonts.tajawal(color: AppColors.primary, fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Drawing board
            Container(
              height: 350,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider),
              ),
              child: GestureDetector(
                onPanStart: (details) {
                  final renderBox = context.findRenderObject() as RenderBox;
                  final localPos = renderBox.globalToLocal(details.globalPosition);
                  setState(() {
                    _localPoints.add(DrawingPoint(x: localPos.dx, y: localPos.dy - 120, isStart: true));
                  });
                  _syncDrawing(coupleId);
                },
                onPanUpdate: (details) {
                  final renderBox = context.findRenderObject() as RenderBox;
                  final localPos = renderBox.globalToLocal(details.globalPosition);
                  setState(() {
                    _localPoints.add(DrawingPoint(x: localPos.dx, y: localPos.dy - 120, isStart: false));
                  });
                  _syncDrawing(coupleId);
                },
                onPanEnd: (details) {
                  _finalizeDrawing(coupleId);
                },
                child: CustomPaint(
                  painter: CanvasPainter(_localPoints),
                  size: Size.infinite,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _localPoints.clear();
                    });
                    ref.read(gameServiceProvider).updateDrawing(coupleId, '[]');
                  },
                  icon: const Icon(Icons.clear_rounded, color: Colors.red),
                  label: Text('مسح اللوحة', style: GoogleFonts.tajawal(color: Colors.red)),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await ref.read(gameServiceProvider).giveUpDrawing(coupleId);
                  },
                  icon: const Icon(Icons.flag_rounded, color: Colors.amber),
                  label: Text('استسلام', style: GoogleFonts.tajawal(color: Colors.amber)),
                ),
              ],
            ),
          ],
        );
      } else {
        // Guesser mode
        List<DrawingPoint> syncedPoints = [];
        if (game.drawingData != '[]' && game.drawingData.isNotEmpty) {
          syncedPoints = game.drawingData.split(';').map((s) => DrawingPoint.deserialize(s)).toList();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '$partnerName يرسم الآن... خمن الرسمة!',
              style: GoogleFonts.tajawal(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              height: 350,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider),
              ),
              child: CustomPaint(
                painter: CanvasPainter(syncedPoints),
                size: Size.infinite,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _guessController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'اكتب تخمينك هنا (مثال: قلب)...',
                hintStyle: GoogleFonts.tajawal(color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            GradientButton(
              text: 'إرسال التخمين 🚀',
              onPressed: () async {
                final guess = _guessController.text.trim();
                if (guess.isEmpty) return;
                await ref.read(gameServiceProvider).guessDrawing(coupleId, guess, myId);
                _guessController.clear();
              },
            ),
          ],
        );
      }
    } else {
      // Guessed or gave_up
      final isGuessed = game.status == 'guessed';
      return Column(
        children: [
          Icon(
            isGuessed ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 72,
            color: isGuessed ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 24),
          Text(
            isGuessed ? '🎉 خمنتها بنجاح! 🎉' : 'انتهت اللعبة دون تخمين 🥺',
            style: GoogleFonts.tajawal(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'الكلمة السرية كانت: ${game.secretWord}',
            style: GoogleFonts.tajawal(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 48),
          GradientButton(
            text: 'تحدٍ جديد 🔄',
            onPressed: () async {
              await ref.read(gameServiceProvider).giveUpDrawing(coupleId);
              // Simply start setup screen by letting them trigger paint/guess setup
              // Delete doc
              await ref.read(gameServiceProvider).updateDrawing(coupleId, '[]');
              await ref.read(gameServiceProvider).giveUpDrawing(coupleId);
              // Actually we can delete this game state to trigger setup
              await ref.read(gameServiceProvider).startDrawGuess(coupleId, myId, game.guesserId, 'heart');
              // Best to delete drawing or reset game state
              await ref.read(gameServiceProvider).updateDrawing(coupleId, '[]');
              await ref.read(gameServiceProvider).giveUpDrawing(coupleId);
            },
          ),
        ],
      );
    }
  }
}

class CanvasPainter extends CustomPainter {
  final List<DrawingPoint> points;

  CanvasPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (!points[i].isStart && !points[i + 1].isStart) {
        canvas.drawLine(
          Offset(points[i].x, points[i].y),
          Offset(points[i + 1].x, points[i + 1].y),
          paint,
        );
      } else if (points[i].isStart) {
        canvas.drawCircle(Offset(points[i].x, points[i].y), 2.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) => true;
}
