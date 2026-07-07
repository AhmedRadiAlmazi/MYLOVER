import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/models/app_models.dart';
import '../providers/memories_provider.dart';
import '../services/memory_service.dart';
import '../../auth/providers/auth_provider.dart';

class MemoryDetailScreen extends ConsumerStatefulWidget {
  const MemoryDetailScreen({super.key});

  @override
  ConsumerState<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends ConsumerState<MemoryDetailScreen> {
  bool _isLiked = false;
  int _likes = 0;
  bool _isInitialized = false;
  String _currentMemoryId = '';
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _showActionsMenu(BuildContext context, MemoryModel memory) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_rounded, color: AppColors.primary),
            title: Text('تعديل الذكرى', style: GoogleFonts.tajawal(color: AppColors.textPrimary)),
            onTap: () {
              Navigator.pop(ctx);
              _showEditMemoryDialog(memory);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_rounded, color: AppColors.error),
            title: Text('حذف الذكرى', style: GoogleFonts.tajawal(color: AppColors.error)),
            onTap: () {
              Navigator.pop(ctx);
              _confirmDeleteMemory(memory);
            },
          ),
        ],
      ),
    );
  }

  void _showEditMemoryDialog(MemoryModel memory) {
    final titleController = TextEditingController(text: memory.title);
    final descController = TextEditingController(text: memory.description);
    final locController = TextEditingController(text: memory.location);
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('تعديل الذكرى', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: GoogleFonts.tajawal(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'العنوان',
                    labelStyle: GoogleFonts.tajawal(color: AppColors.textHint),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  style: GoogleFonts.tajawal(color: AppColors.textPrimary),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'الوصف',
                    labelStyle: GoogleFonts.tajawal(color: AppColors.textHint),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locController,
                  style: GoogleFonts.tajawal(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'الموقع',
                    labelStyle: GoogleFonts.tajawal(color: AppColors.textHint),
                  ),
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
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: () async {
                      setStateDialog(() => isSaving = true);
                      try {
                        final user = ref.read(currentUserProvider).value;
                        if (user != null && user.partnerId != null) {
                          final updatedMemory = MemoryModel(
                            id: memory.id,
                            title: titleController.text.trim(),
                            description: descController.text.trim(),
                            location: locController.text.trim(),
                            mediaUrl: memory.mediaUrl,
                            category: memory.category,
                            date: memory.date,
                            likes: memory.likes,
                            isLiked: memory.isLiked,
                            colorIndex: memory.colorIndex,
                          );
                          final service = ref.read(memoryServiceProvider);
                          await service.updateMemory(
                            userId: user.id,
                            partnerId: user.partnerId!,
                            memory: updatedMemory,
                          );
                          ref.read(selectedMemoryProvider.notifier).state = updatedMemory;
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

  void _confirmDeleteMemory(MemoryModel memory) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('حذف الذكرى', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.error)),
        content: Text('هل أنت متأكد من حذف هذه الذكرى نهائياً؟', style: GoogleFonts.tajawal(color: AppColors.textPrimary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء', style: GoogleFonts.tajawal(color: AppColors.textHint)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              try {
                final user = ref.read(currentUserProvider).value;
                if (user != null && user.partnerId != null) {
                  final service = ref.read(memoryServiceProvider);
                  await service.deleteMemory(user.id, user.partnerId!, memory.id);
                }
                if (mounted) {
                  Navigator.pop(ctx);
                  context.pop();
                }
              } catch (e) {
                // Error
              }
            },
            child: Text('حذف', style: GoogleFonts.tajawal()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final memory = ref.watch(selectedMemoryProvider);
    final currentUser = ref.watch(currentUserProvider).value;

    if (memory == null || currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Text('الذكرى غير موجودة أو لم يتم تسجيل الدخول', style: GoogleFonts.tajawal(color: Colors.white, fontSize: 18)),
        ),
      );
    }

    if (!_isInitialized || _currentMemoryId != memory.id) {
      _isLiked = memory.isLiked;
      _likes = memory.likes;
      _currentMemoryId = memory.id;
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
            backgroundColor: AppColors.background.withOpacity(0.95),
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
                onPressed: () {
                  Share.share('${memory.title}\n${memory.description ?? ''}');
                },
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
                onPressed: () => _showActionsMenu(context, memory),
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
                        onTap: () async {
                          final user = ref.read(currentUserProvider).value;
                          if (user != null && user.partnerId != null) {
                            final service = ref.read(memoryServiceProvider);
                            setState(() {
                              _isLiked = !_isLiked;
                              _likes += _isLiked ? 1 : -1;
                            });
                            await service.toggleLike(user.id, user.partnerId!, memory.id, !_isLiked, _likes);
                          }
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

                  // Comments Section
                  Text(
                    'التعليقات',
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  StreamBuilder<List<MemoryCommentModel>>(
                    stream: ref.read(memoryServiceProvider).getCommentsStream(
                          userId: currentUser.id,
                          partnerId: currentUser.partnerId!,
                          memoryId: memory.id,
                        ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                      }
                      final comments = snapshot.data ?? [];
                      if (comments.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text('لا توجد تعليقات بعد. اكتب أول تعليق!', style: GoogleFonts.tajawal(color: AppColors.textHint, fontSize: 13)),
                        );
                      }
                      return Column(
                        children: comments.map((c) {
                          final timeStr = DateFormat('jm', 'ar').format(c.createdAt);
                          return _buildComment(c.userName, c.text, timeStr);
                        }).toList(),
                      );
                    },
                  ),

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
                              onPressed: () async {
                                final text = _commentController.text.trim();
                                if (text.isEmpty) return;
                                _commentController.clear();
                                
                                try {
                                  final service = ref.read(memoryServiceProvider);
                                  final comment = MemoryCommentModel(
                                    id: const Uuid().v4(),
                                    userName: currentUser.name,
                                    text: text,
                                    createdAt: DateTime.now(),
                                  );
                                  await service.addComment(
                                    userId: currentUser.id,
                                    partnerId: currentUser.partnerId!,
                                    memoryId: memory.id,
                                    comment: comment,
                                  );
                                } catch (e) {
                                  // Error
                                }
                              },
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
