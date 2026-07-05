import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/app_models.dart' hide currentUserProvider;
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/services/storage_service.dart';
import '../../memories/providers/memories_provider.dart';
import '../../auth/providers/auth_provider.dart';

class DrawingScreen extends ConsumerStatefulWidget {
  const DrawingScreen({super.key});

  @override
  ConsumerState<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends ConsumerState<DrawingScreen> {
  final List<_DrawnLine> _lines = [];
  List<Offset> _currentLine = [];
  Color _selectedColor = AppColors.secondary;
  double _strokeWidth = 4.0;
  bool _isErasing = false;
  bool _isSaving = false;

  final GlobalKey _canvasKey = GlobalKey();

  final List<Color> _colors = [
    AppColors.secondary,
    AppColors.primary,
    AppColors.accent,
    AppColors.success,
    Colors.white,
    Colors.orange,
    Colors.cyan,
    Colors.purple,
  ];

  Future<void> _saveDrawingToMemories() async {
    if (_lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اللوحة فارغة!')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null || user.partnerId == null) throw Exception('المستخدم غير متصل بالشريك');

      // 1. Capture the widget as an image
      RenderRepaintBoundary boundary = _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 2. Upload to Firebase Storage
      final storageService = StorageService();
      final imageUrl = await storageService.uploadBytes(pngBytes, 'shared_drawings');

      // 3. Save as Memory in Firestore
      final newMemory = MemoryModel(
        id: const Uuid().v4(),
        title: 'لوحة فنية مشتركة 🎨',
        description: 'رسمة تم إنشاؤها في: ${DateTime.now().hour}:${DateTime.now().minute}',
        mediaUrl: imageUrl,
        category: MemoryCategory.photo,
        date: DateTime.now(),
      );

      await ref.read(memoryServiceProvider).addMemory(
            memory: newMemory,
            userId: user.id,
            partnerId: user.partnerId!,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ الرسمة في ألبوم الذكريات بنجاح! ❤️')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ أثناء الحفظ: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withOpacity(0.95),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary), onPressed: () => context.pop()),
        title: Text('الرسم المشترك 🎨', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 20)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.undo_rounded, color: AppColors.textPrimary), onPressed: () { if (_lines.isNotEmpty) setState(() => _lines.removeLast()); }),
          IconButton(icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error), onPressed: () => setState(() => _lines.clear())),
          if (_isSaving)
            const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))))
          else
            IconButton(icon: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28), onPressed: _saveDrawingToMemories),
        ],
      ),
      body: Column(
        children: [
          // Canvas
          Expanded(
            child: GestureDetector(
              onPanStart: (d) { setState(() { _currentLine = [d.localPosition]; }); },
              onPanUpdate: (d) { setState(() { _currentLine.add(d.localPosition); }); },
              onPanEnd: (_) {
                setState(() {
                  _lines.add(_DrawnLine(List.from(_currentLine), _isErasing ? AppColors.background : _selectedColor, _isErasing ? 20 : _strokeWidth));
                  _currentLine = [];
                });
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF12121E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: RepaintBoundary(
                    key: _canvasKey,
                    child: Container(
                      color: const Color(0xFF12121E), // Explicit background for the saved image
                      child: CustomPaint(
                        painter: _DrawingPainter(_lines, _currentLine, _isErasing ? AppColors.background : _selectedColor, _strokeWidth),
                        child: Center(
                          child: _lines.isEmpty && _currentLine.isEmpty
                              ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  const Text('🎨', style: TextStyle(fontSize: 48)),
                                  const SizedBox(height: 12),
                                  Text('ارسم شيئاً جميلاً!', style: GoogleFonts.tajawal(color: AppColors.textHint, fontSize: 16)),
                                ])
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Toolbar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.divider))),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  // Colors
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ..._colors.map((c) => GestureDetector(
                        onTap: () => setState(() { _selectedColor = c; _isErasing = false; }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 32, height: 32,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(color: (!_isErasing && _selectedColor == c) ? Colors.white : Colors.transparent, width: 3),
                            boxShadow: (!_isErasing && _selectedColor == c) ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 8, spreadRadius: 2)] : null,
                          ),
                        ),
                      )),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _isErasing = !_isErasing),
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: _isErasing ? AppColors.primary : AppColors.card,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: const Icon(Icons.auto_fix_normal_rounded, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Stroke width
                  Row(
                    children: [
                      const Icon(Icons.brush_rounded, color: AppColors.textHint, size: 16),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(activeTrackColor: _selectedColor, thumbColor: _selectedColor, inactiveTrackColor: AppColors.divider),
                          child: Slider(value: _strokeWidth, min: 1, max: 20, onChanged: (v) => setState(() => _strokeWidth = v)),
                        ),
                      ),
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: _isErasing ? Colors.white : _selectedColor),
                        child: Center(child: Container(width: _strokeWidth.clamp(2, 20), height: _strokeWidth.clamp(2, 20), decoration: BoxDecoration(shape: BoxShape.circle, color: _isErasing ? AppColors.background : Colors.black.withOpacity(0.3)))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawnLine {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  _DrawnLine(this.points, this.color, this.strokeWidth);
}

class _DrawingPainter extends CustomPainter {
  final List<_DrawnLine> lines;
  final List<Offset> currentLine;
  final Color currentColor;
  final double currentWidth;

  _DrawingPainter(this.lines, this.currentLine, this.currentColor, this.currentWidth);

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in lines) {
      final paint = Paint()
        ..color = line.color
        ..strokeWidth = line.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      if (line.points.length > 1) {
        final path = Path()..moveTo(line.points.first.dx, line.points.first.dy);
        for (int i = 1; i < line.points.length; i++) path.lineTo(line.points[i].dx, line.points[i].dy);
        canvas.drawPath(path, paint);
      }
    }
    if (currentLine.length > 1) {
      final paint = Paint()..color = currentColor..strokeWidth = currentWidth..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke;
      final path = Path()..moveTo(currentLine.first.dx, currentLine.first.dy);
      for (int i = 1; i < currentLine.length; i++) path.lineTo(currentLine[i].dx, currentLine[i].dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
