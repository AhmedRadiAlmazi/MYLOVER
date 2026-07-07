import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/app_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../wishes/services/wishes_service.dart';
import '../../auth/providers/auth_provider.dart';

class BucketListScreen extends ConsumerStatefulWidget {
  const BucketListScreen({super.key});

  @override
  ConsumerState<BucketListScreen> createState() => _BucketListScreenState();
}

class _BucketListScreenState extends ConsumerState<BucketListScreen> {
  void _showAddItemDialog() {
    final titleController = TextEditingController();
    String selectedCategory = 'سفر';
    IconData selectedIcon = Icons.flight_takeoff_rounded;
    bool isSaving = false;

    final categories = {
      'سفر': Icons.flight_takeoff_rounded,
      'مستقبل': Icons.home_rounded,
      'مغامرات': Icons.explore_rounded,
      'ترفيه': Icons.movie_rounded,
      'رياضة': Icons.sports_soccer_rounded,
    };

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'أضف هدفاً لـ Bucket List',
            style: GoogleFonts.tajawal(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: GoogleFonts.tajawal(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'اسم الهدف (مثال: رؤية الشفق القطبي)',
                    hintStyle: GoogleFonts.tajawal(color: AppColors.textHint),
                    filled: true,
                    fillColor: AppColors.card,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                Text('اختر التصنيف والأيقونة:', style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.entries.map((entry) {
                    final isSelected = selectedCategory == entry.key;
                    return GestureDetector(
                      onTap: () {
                        setStateDialog(() {
                          selectedCategory = entry.key;
                          selectedIcon = entry.value;
                        });
                      },
                      child: Chip(
                        backgroundColor: isSelected ? AppColors.primary.withOpacity(0.2) : AppColors.card,
                        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.divider),
                        avatar: Icon(entry.value, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 18),
                        label: Text(entry.key, style: GoogleFonts.tajawal(color: isSelected ? AppColors.primary : AppColors.textPrimary, fontSize: 12)),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
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
                          final newWish = WishModel(
                            id: const Uuid().v4(),
                            title: titleController.text.trim(),
                            category: selectedCategory,
                            icon: selectedIcon,
                            isCompleted: false,
                            dateAdded: DateTime.now(),
                            isBucketList: true,
                          );
                          
                          final service = ref.read(wishesServiceProvider);
                          await service.addWish(
                            wish: newWish,
                            userId: user.id,
                            partnerId: user.partnerId!,
                          );
                        }
                        if (mounted) Navigator.pop(context);
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
    final bucketListAsync = ref.watch(bucketListStreamProvider);
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
        title: Text('Bucket List 🎯', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 20)),
        centerTitle: true,
      ),
      body: bucketListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('حدث خطأ في تحميل القائمة', style: GoogleFonts.tajawal(color: Colors.white))),
        data: (allWishes) {
          final items = allWishes.where((w) => w.isBucketList).toList();
          final completed = items.where((i) => i.isCompleted).length;

          if (items.isEmpty) {
            return Center(
              child: EmptyStateWidget(
                icon: Icons.track_changes_rounded,
                title: 'لا توجد أهداف بعد',
                subtitle: 'أضف أهدافاً وأحلاماً تود تحقيقها مع شريكك',
                actionText: 'إضافة هدف',
                action: _showAddItemDialog,
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Progress card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Text('أنجزتم معاً', style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('$completed / ${items.length}', style: GoogleFonts.tajawal(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: items.isNotEmpty ? (completed / items.length) : 0.0,
                            backgroundColor: Colors.white30,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                            minHeight: 10,
                          ),
                        ),
                      ],
                    ),
                  ).animate().scale().fadeIn(),
                ),
              ),

              // Grid of bucket list items
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final item = items[i];
                      return GestureDetector(
                        onTap: () async {
                          if (user != null && user.partnerId != null) {
                            final service = ref.read(wishesServiceProvider);
                            await service.toggleWish(item.id, !item.isCompleted, user.id, user.partnerId!);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: item.isCompleted ? AppColors.success.withOpacity(0.1) : AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: item.isCompleted ? AppColors.success.withOpacity(0.5) : AppColors.divider,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      item.icon,
                                      size: 36,
                                      color: item.isCompleted ? AppColors.success : AppColors.primary,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item.title,
                                      style: GoogleFonts.tajawal(
                                        color: item.isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                                        fontSize: 12,
                                        decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (item.isCompleted)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.success),
                                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ).animate().scale(delay: Duration(milliseconds: i * 50)).fadeIn(delay: Duration(milliseconds: i * 50));
                    },
                    childCount: items.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: _showAddItemDialog,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }
}
