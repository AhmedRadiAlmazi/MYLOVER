import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../features/gift_library/services/gift_service.dart';
import '../../auth/providers/auth_provider.dart';

final giftServiceProvider = Provider<GiftService>((ref) => GiftService());

final giftsStreamProvider = StreamProvider<List<GiftModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null || user.partnerId == null || user.partnerId!.isEmpty) {
    return Stream.value([]);
  }
  return ref.watch(giftServiceProvider).getGiftsStream(user.id, user.partnerId!);
});

class GiftLibraryScreen extends ConsumerStatefulWidget {
  const GiftLibraryScreen({super.key});

  @override
  ConsumerState<GiftLibraryScreen> createState() => _GiftLibraryScreenState();
}

class _GiftLibraryScreenState extends ConsumerState<GiftLibraryScreen> {
  void _showAddGiftDialog() {
    final titleController = TextEditingController();
    final priceController = TextEditingController();
    String intendedFor = 'partner';
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('فكرة هدية جديدة 🎁', style: GoogleFonts.tajawal(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: GoogleFonts.tajawal(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'ما هي الهدية؟ (مثال: ساعة)',
                  hintStyle: GoogleFonts.tajawal(color: AppColors.textHint),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                style: GoogleFonts.tajawal(color: AppColors.textPrimary),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'السعر التقريبي...',
                  hintStyle: GoogleFonts.tajawal(color: AppColors.textHint),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: intendedFor,
                dropdownColor: AppColors.card,
                style: GoogleFonts.tajawal(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: [
                  DropdownMenuItem(value: 'partner', child: Text('لشريكي', style: GoogleFonts.tajawal())),
                  DropdownMenuItem(value: 'me', child: Text('لنفسي (أمنية)', style: GoogleFonts.tajawal())),
                ],
                onChanged: (val) {
                  if (val != null) setStateDialog(() => intendedFor = val);
                },
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
                      if (titleController.text.trim().isEmpty) return;
                      setStateDialog(() => isSaving = true);
                      
                      try {
                        final user = ref.read(currentUserProvider).value;
                        if (user != null && user.partnerId != null) {
                          final newGift = GiftModel(
                            id: const Uuid().v4(),
                            title: titleController.text.trim(),
                            price: priceController.text.trim().isEmpty ? 'غير محدد' : priceController.text.trim(),
                            category: 'عام',
                            icon: Icons.card_giftcard_rounded,
                            createdAt: DateTime.now(),
                            intendedFor: intendedFor,
                          );
                          await ref.read(giftServiceProvider).addGift(gift: newGift, userId: user.id, partnerId: user.partnerId!);
                        }
                        if (mounted) Navigator.pop(ctx);
                      } catch (e) {
                        setStateDialog(() => isSaving = false);
                      }
                    },
                    child: Text('إضافة', style: GoogleFonts.tajawal()),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final giftsAsync = ref.watch(giftsStreamProvider);
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withOpacity(0.95),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary), onPressed: () => context.pop()),
        title: Text('مكتبة الهدايا', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 20)),
        centerTitle: true,
      ),
      body: giftsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('خطأ: $err', style: const TextStyle(color: Colors.white))),
        data: (gifts) {
          if (gifts.isEmpty) {
            return Center(
              child: Text('المكتبة فارغة حالياً. أضف أفكاراً للهدايا!', style: GoogleFonts.tajawal(color: AppColors.textHint)),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.75,
            ),
            itemCount: gifts.length,
            itemBuilder: (context, i) {
              final gift = gifts[i];
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.card, 
                  borderRadius: BorderRadius.circular(20), 
                  border: Border.all(color: gift.isPurchased ? AppColors.success.withOpacity(0.5) : AppColors.divider)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity, height: 100,
                      decoration: BoxDecoration(
                        gradient: gift.isPurchased ? AppColors.goldGradient : AppColors.cardGradient, 
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20))
                      ),
                      child: Stack(
                        children: [
                          Center(child: Icon(gift.icon, size: 48, color: gift.isPurchased ? Colors.black54 : Colors.white)),
                          Positioned(
                            top: 8, right: 8,
                            child: IconButton(
                              icon: Icon(gift.isPurchased ? Icons.check_circle_rounded : Icons.radio_button_unchecked, color: gift.isPurchased ? Colors.white : Colors.white54),
                              onPressed: () {
                                if (user != null && user.partnerId != null) {
                                  ref.read(giftServiceProvider).togglePurchased(
                                    giftId: gift.id, 
                                    isPurchased: !gift.isPurchased, 
                                    userId: user.id, 
                                    partnerId: user.partnerId!
                                  );
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(gift.title, style: GoogleFonts.tajawal(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(gift.intendedFor == 'me' ? 'أمنية لي' : 'هدية للشريك', style: GoogleFonts.tajawal(color: AppColors.secondary, fontSize: 11)),
                        const SizedBox(height: 6),
                        Text('السعر: ${gift.price}', style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 11)),
                      ]),
                    ),
                  ],
                ),
              ).animate().scale(delay: Duration(milliseconds: i * 60)).fadeIn(delay: Duration(milliseconds: i * 60));
            },
          );
        }
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: _showAddGiftDialog,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }
}

