import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../features/map/services/map_service.dart';
import '../../auth/providers/auth_provider.dart';

final mapServiceProvider = Provider<MapService>((ref) => MapService());

final pinsStreamProvider = StreamProvider<List<MapPinModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null || user.partnerId == null || user.partnerId!.isEmpty) {
    return Stream.value([]);
  }
  return ref.watch(mapServiceProvider).getPinsStream(user.id, user.partnerId!);
});

class MemoryMapScreen extends ConsumerStatefulWidget {
  const MemoryMapScreen({super.key});

  @override
  ConsumerState<MemoryMapScreen> createState() => _MemoryMapScreenState();
}

class _MemoryMapScreenState extends ConsumerState<MemoryMapScreen> {
  void _showAddPinDialog() {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('إضافة موقع جديد 📍', style: GoogleFonts.tajawal(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: GoogleFonts.tajawal(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'عنوان الذكرى (مثال: أول لقاء)',
                  hintStyle: GoogleFonts.tajawal(color: AppColors.textHint),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                style: GoogleFonts.tajawal(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'اسم المكان (مثال: دبي مول)',
                  hintStyle: GoogleFonts.tajawal(color: AppColors.textHint),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: Text('إلغاء', style: GoogleFonts.tajawal(color: AppColors.textHint)),
            ),
            isSaving
                ? const CircularProgressIndicator(color: AppColors.primary)
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: () async {
                      if (titleController.text.trim().isEmpty || locationController.text.trim().isEmpty) return;
                      setStateDialog(() => isSaving = true);
                      
                      try {
                        final user = ref.read(currentUserProvider).value;
                        if (user != null && user.partnerId != null) {
                          final newPin = MapPinModel(
                            id: const Uuid().v4(),
                            title: titleController.text.trim(),
                            location: locationController.text.trim(),
                            icon: Icons.favorite_rounded,
                            lat: Random().nextDouble() * 180 - 90, // Random for mockup
                            lng: Random().nextDouble() * 360 - 180, // Random for mockup
                            createdAt: DateTime.now(),
                          );
                          await ref.read(mapServiceProvider).addPin(pin: newPin, userId: user.id, partnerId: user.partnerId!);
                        }
                        if (mounted) Navigator.pop(ctx);
                      } catch (e) {
                        setStateDialog(() => isSaving = false);
                      }
                    },
                    child: Text('حفظ', style: GoogleFonts.tajawal()),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pinsAsync = ref.watch(pinsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withOpacity(0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('خريطة الذكريات', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 20)),
        centerTitle: true,
      ),
      body: pinsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('خطأ: $err', style: const TextStyle(color: Colors.white))),
        data: (pins) {
          return Column(
            children: [
              // Map placeholder
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A3A2A), Color(0xFF2A4A3A), Color(0xFF1A2A3A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.map_rounded, size: 60, color: Colors.white),
                            const SizedBox(height: 12),
                            Text('خريطة ذكرياتنا', style: GoogleFonts.tajawal(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('${pins.length} مواقع محفوظة', style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 13)),
                            const SizedBox(height: 20),
                            Text('(تكامل الخريطة الفعلي يتطلب Google Maps API)', style: GoogleFonts.tajawal(color: Colors.white38, fontSize: 11), textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                      // Mock pins visually distributed based on order
                      ...List.generate(pins.length, (i) {
                        // Just scatter them visually on the mock map background
                        final double leftOffset = 20.0 + (i * 70 % 250);
                        final double topOffset = 20.0 + (i * 90 % 200);
                        return Positioned(
                          left: leftOffset,
                          top: topOffset,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                child: Icon(pins[i].icon, size: 16, color: Colors.white),
                              ),
                              Container(width: 2, height: 20, color: AppColors.secondary),
                            ],
                          ).animate(delay: Duration(milliseconds: i * 150)).scale().fadeIn(),
                        );
                      }),
                    ],
                  ),
                ).animate().fadeIn(),
              ),

              // Pins list
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('المواقع المحفوظة', style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ),
                    if (pins.isEmpty)
                      Expanded(
                        child: Center(
                          child: Text('لا توجد مواقع محفوظة بعد. ابدأ بإضافة أول مكان!', style: GoogleFonts.tajawal(color: AppColors.textHint)),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: pins.length,
                          itemBuilder: (context, i) {
                            final pin = pins[i];
                            return Container(
                              width: 140,
                              margin: const EdgeInsets.only(left: 12, bottom: 8),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                              ),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Icon(pin.icon, size: 28, color: AppColors.primary),
                                const SizedBox(height: 8),
                                Text(pin.title, style: GoogleFonts.tajawal(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(pin.location, style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 11)),
                              ]),
                            ).animate().slideX(delay: Duration(milliseconds: i * 80)).fadeIn(delay: Duration(milliseconds: i * 80));
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent, 
          elevation: 0, 
          onPressed: _showAddPinDialog, 
          child: const Icon(Icons.add_location_rounded, color: Colors.white)
        ),
      ),
    );
  }
}

