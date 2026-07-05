import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/models/app_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../providers/memories_provider.dart';

class MemoryDetailScreen extends ConsumerStatefulWidget {
  const MemoryDetailScreen({super.key});

  @override
  ConsumerState<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends ConsumerState<MemoryDetailScreen> {
  bool _isLiked = false;
  int _likes = 0;
  bool _isInitialized = false;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memory = ref.watch(selectedMemoryProvider);

    if (memory == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Text('الذكرى غير موجودة', style: GoogleFonts.tajawal(color: Colors.white, fontSize: 18)),
        ),
      );
    }

    if (!_isInitialized) {
      _isLiked = memory.isLiked;
      _likes = memory.likes;
      _isInitialized = true;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero Image
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: AppColors.background.withOpacity(0.9),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share_rounded, color: Colors.white, size: 18),
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 18),
                ),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'memory_${memory.id}',
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    image: memory.mediaUrl != null
                        ? DecorationImage(
                            image: getSmartImageProvider(memory.mediaUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: memory.mediaUrl == null
                      ? const Center(
                          child: Icon(Icons.image_rounded, size: 80, color: Colors.white54),
                        )
                      : null,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Date
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          memory.title,
                          style: GoogleFonts.tajawal(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      // Like Button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLiked = !_isLiked;
                            _likes += _isLiked ? 1 : -1;
                          });
                        },
                        child: Row(
                          children: [
                            Icon(
                              _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: _isLiked ? AppColors.secondary : AppColors.textHint,
                              size: 28,
                            )
                                .animate(target: _isLiked ? 1 : 0)
                                .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3))
                                .then()
                                .scale(begin: const Offset(1.3, 1.3), end: const Offset(1, 1)),
                            const SizedBox(width: 6),
                            Text(
                              '$_likes',
                              style: GoogleFonts.tajawal(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Meta Info
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('d MMMM yyyy', 'ar').format(memory.date),
                        style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 14),
                      ),
                      if (memory.location != null && memory.location!.isNotEmpty) ...[
                        const SizedBox(width: 20),
                        const Icon(Icons.location_on_rounded, size: 16, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        Text(
                          memory.location!,
                          style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 14),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Description
                  Text(
                    'الوصف',
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (memory.description != null && memory.description!.isNotEmpty) 
                        ? memory.description! 
                        : 'لا يوجد وصف لهذه الذكرى.',
                    style: GoogleFonts.tajawal(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 16),

                  // Comments Section (Hardcoded for now)
                  Text(
                    'التعليقات',
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildComment('شريكك', 'ذكرى جميلة جداً ❤️', 'الآن'),

                  const SizedBox(height: 16),

                  // Add Comment
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          style: GoogleFonts.tajawal(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'أضف تعليقاً...',
                            hintStyle: GoogleFonts.tajawal(color: AppColors.textHint),
                            filled: true,
                            fillColor: AppColors.card,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                              onPressed: () {},
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComment(String name, String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.roseGradient,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0] : 'ش',
                style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: GoogleFonts.tajawal(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: GoogleFonts.tajawal(
              color: AppColors.textHint,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
