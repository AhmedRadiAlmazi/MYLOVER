import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../providers/memories_provider.dart';

class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real app, you would fetch only photos from memories
    final memories = ref.watch(filteredMemoriesProvider);
    final photoMemories = memories.where((m) => m.mediaUrl != null).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'معرض الصور',
          style: GoogleFonts.tajawal(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: photoMemories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.photo_library_outlined, size: 80, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد صور بعد',
                    style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 18),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: photoMemories.length,
              itemBuilder: (context, index) {
                final memory = photoMemories[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to image viewer
                    // Pass image URL as extra
                    context.push('/image-viewer', extra: memory.mediaUrl);
                  },
                  child: Hero(
                    tag: 'gallery_image_${memory.id}',
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                        image: memory.mediaUrl != null
                            ? DecorationImage(
                                image: getSmartImageProvider(memory.mediaUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
