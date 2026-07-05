import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models/app_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';

class BucketListScreen extends ConsumerWidget {
  const BucketListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = WishModel.mockBucketList;
    final completed = items.where((i) => i.isCompleted).length;

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
      body: CustomScrollView(
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
                  boxShadow: [BoxShadow(color: AppColors.primaryDark.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 6))],
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
                        value: completed / items.length,
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
                  return Container(
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
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () {},
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }
}
