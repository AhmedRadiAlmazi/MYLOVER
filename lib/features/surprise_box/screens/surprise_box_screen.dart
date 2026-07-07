import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../features/surprise_box/services/surprise_service.dart';
import '../../../core/services/storage_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/models/app_models.dart';

final surpriseServiceProvider = Provider<SurpriseService>((ref) => SurpriseService());

final surprisesStreamProvider = StreamProvider<List<SurpriseModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null || user.partnerId == null || user.partnerId!.isEmpty) {
    return Stream.value([]);
  }
  return ref.watch(surpriseServiceProvider).getSurprisesStream(user.id, user.partnerId!);
});

class SurpriseBoxScreen extends ConsumerStatefulWidget {
  const SurpriseBoxScreen({super.key});

  @override
  ConsumerState<SurpriseBoxScreen> createState() => _SurpriseBoxScreenState();
}

class _SurpriseBoxScreenState extends ConsumerState<SurpriseBoxScreen> with SingleTickerProviderStateMixin {
  int? _openedIndex;
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openBox(SurpriseModel surprise, int index, UserModel user) {
    // If it's closed and the user is NOT the creator, mark as opened.
    if (!surprise.isOpened && surprise.createdBy != user.id) {
      ref.read(surpriseServiceProvider).markAsOpened(surprise.id, user.id, user.partnerId!);
    }
    
    // Creators can't "open" it if it's meant for the partner, but they can view it.
    // However, for simplicity, clicking it just shows the content.
    setState(() => _openedIndex = index);
    _controller.reset();
    _controller.forward();
    _showSurpriseDialog(surprise);
  }

  void _showSurpriseDialog(SurpriseModel item) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: AppColors.primaryDark.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 10))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.imageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SmartImage(
                      imageUrl: item.imageUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  Icon(item.icon, size: 56, color: Colors.white).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 12),
                ],
                Text(item.title, style: GoogleFonts.tajawal(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(
                  item.message,
                  style: GoogleFonts.tajawal(color: Colors.white.withOpacity(0.9), fontSize: 15, height: 1.6),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: Text('شكراً ❤️', style: GoogleFonts.tajawal(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    bool isSaving = false;
    File? selectedImage;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('إرسال مفاجأة', style: GoogleFonts.tajawal(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: GoogleFonts.tajawal(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'عنوان المفاجأة',
                  hintStyle: GoogleFonts.tajawal(color: AppColors.textHint),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageController,
                style: GoogleFonts.tajawal(color: AppColors.textPrimary),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك الجميلة هنا...',
                  hintStyle: GoogleFonts.tajawal(color: AppColors.textHint),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 50,
                    maxWidth: 800,
                    maxHeight: 800,
                  );
                  if (pickedFile != null) {
                    setStateDialog(() => selectedImage = File(pickedFile.path));
                  }
                },
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    image: selectedImage != null 
                      ? DecorationImage(image: FileImage(selectedImage!), fit: BoxFit.cover)
                      : null,
                  ),
                  child: selectedImage == null 
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_photo_alternate_rounded, color: AppColors.primary, size: 36),
                          const SizedBox(height: 8),
                          Text('إضافة صورة (اختياري)', style: GoogleFonts.tajawal(color: AppColors.primary)),
                        ],
                      )
                    : Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                          onPressed: () => setStateDialog(() => selectedImage = null),
                        ),
                      ),
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
                      if (titleController.text.trim().isEmpty || messageController.text.trim().isEmpty) return;
                      setStateDialog(() => isSaving = true);
                      
                      try {
                        final user = ref.read(currentUserProvider).value;
                        if (user != null && user.partnerId != null) {
                          String? imageUrl;
                          if (selectedImage != null) {
                            final storageService = StorageService();
                            imageUrl = await storageService.uploadFile(selectedImage!, 'surprises');
                          }
                          
                          final newSurprise = SurpriseModel(
                            id: const Uuid().v4(),
                            title: titleController.text.trim(),
                            message: messageController.text.trim(),
                            icon: Icons.auto_awesome_rounded,
                            createdBy: user.id,
                            createdAt: DateTime.now(),
                            imageUrl: imageUrl,
                          );
                          await ref.read(surpriseServiceProvider).addSurprise(surprise: newSurprise, userId: user.id, partnerId: user.partnerId!);
                        }
                        if (mounted) Navigator.pop(ctx);
                      } catch (e) {
                        setStateDialog(() => isSaving = false);
                      }
                    },
                    child: Text('إرسال', style: GoogleFonts.tajawal()),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final surprisesAsync = ref.watch(surprisesStreamProvider);
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withOpacity(0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('صندوق المفاجآت', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Description
            GlassCard(
              child: Row(
                children: [
                  const Icon(Icons.theater_comedy_rounded, size: 36, color: AppColors.primary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('مفاجآت من القلب', style: GoogleFonts.tajawal(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('اضغط على أي صندوق لفتح مفاجأة جميلة!', style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),

            const SizedBox(height: 24),
            Text('اختر صندوقاً', style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)).animate().fadeIn(),
            const SizedBox(height: 16),

            surprisesAsync.when(
              loading: () => const CircularProgressIndicator(color: AppColors.primary),
              error: (err, _) => Text('خطأ: $err', style: const TextStyle(color: Colors.white)),
              data: (surprises) {
                if (surprises.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text('لا توجد مفاجآت بعد.. بادر بإرسال الأولى!', style: GoogleFonts.tajawal(color: AppColors.textHint)),
                    ),
                  );
                }
                
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.1,
                  ),
                  itemCount: surprises.length,
                  itemBuilder: (context, i) {
                    final surprise = surprises[i];
                    // If created by me, I can see it's my sent box. If it's opened, show different icon.
                    final isOpened = surprise.isOpened || _openedIndex == i;
                    final isMine = surprise.createdBy == user?.id;

                    return GestureDetector(
                      onTap: () {
                        if (user != null) _openBox(surprise, i, user);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        decoration: BoxDecoration(
                          gradient: isOpened 
                              ? null // Opened: flat color
                              : (isMine ? AppColors.cardGradient : AppColors.roseGradient), // Unopened: Rose if for me, Card if mine
                          color: isOpened ? AppColors.cardLight : null, // Opened: Flat card color
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isOpened 
                              ? AppColors.divider 
                              : (isMine ? AppColors.divider : AppColors.primary),
                            width: isOpened ? 1 : 2,
                          ),
                          boxShadow: (!isOpened && !isMine) 
                              ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 15, spreadRadius: 2)] 
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isOpened ? surprise.icon : (isMine ? Icons.lock_clock_rounded : Icons.card_giftcard_rounded), 
                              size: 44, 
                              color: isOpened ? AppColors.primary.withOpacity(0.7) : (isMine ? AppColors.textHint : Colors.white)
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isOpened 
                                ? surprise.title 
                                : (isMine ? 'تم الإرسال (مغلق)' : 'هدية جديدة لك!'),
                              style: GoogleFonts.tajawal(
                                color: isOpened 
                                  ? AppColors.textPrimary 
                                  : (isMine ? AppColors.textSecondary : Colors.white),
                                fontWeight: FontWeight.bold,
                                fontSize: isOpened ? 13 : 14,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                            if (!isOpened && !isMine)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text('اضغط للفتح ✨', style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 11)),
                              ).animate(onPlay: (controller) => controller.repeat(reverse: true)).fadeIn(duration: 800.ms).moveY(begin: -2, end: 2),
                          ],
                        ),
                      ).animate(delay: Duration(milliseconds: i * 80)).scale().fadeIn(),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 24),

            // Add surprise button
            GradientButton(
              text: 'إرسال مفاجأة جديدة',
              onPressed: _showAddDialog,
              gradient: AppColors.roseGradient,
            ).animate().slideY(delay: 400.ms).fadeIn(delay: 400.ms),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

