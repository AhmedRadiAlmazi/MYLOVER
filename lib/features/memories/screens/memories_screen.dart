import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/app_models.dart' hide currentUserProvider;
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/services/storage_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/memories_provider.dart';

class MemoriesScreen extends ConsumerStatefulWidget {
  const MemoriesScreen({super.key});

  @override
  ConsumerState<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends ConsumerState<MemoriesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedFilter = 0;
  bool _isUploading = false;

  final List<String> _filters = ['الكل', 'صور', 'فيديو', 'مناسبات'];
  final List<int> _memoryColors = [
    0xFF6B2FBE, 0xFFE5447A, 0xFF1A6B4A, 0xFF4A1A6B,
    0xFF6B4A1A, 0xFF1A4A6B, 0xFF6B1A4A, 0xFF4A6B1A,
    0xFF8B3FD9, 0xFFFF6B9D, 0xFF3F8BD9, 0xFFD98B3F,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onFilterTap(int index) {
    setState(() => _selectedFilter = index);
    MemoryCategory? category;
    if (index == 1) category = MemoryCategory.photo;
    if (index == 2) category = MemoryCategory.video;
    if (index == 3) category = MemoryCategory.occasion;
    
    ref.read(selectedCategoryProvider.notifier).state = category;
  }

  Future<void> _uploadNewMemory() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final titleController = TextEditingController();
    
    // Show dialog to enter title
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('إضافة ذكرى جديدة', style: GoogleFonts.tajawal(color: AppColors.textPrimary)),
        content: TextField(
          controller: titleController,
          style: GoogleFonts.tajawal(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'ماذا تود أن تسمي هذه الذكرى؟',
            hintStyle: GoogleFonts.tajawal(color: AppColors.textHint),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('إلغاء', style: GoogleFonts.tajawal(color: AppColors.textHint)),
          ),
          GradientButton(
            text: 'حفظ الذكرى',
            width: 120,
            height: 40,
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm != true || titleController.text.trim().isEmpty) return;

    setState(() => _isUploading = true);

    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null || user.partnerId == null) throw Exception('بيانات المستخدم غير مكتملة');

      // Upload image
      final storageService = StorageService();
      final imageUrl = await storageService.uploadFile(File(pickedFile.path), 'memories');

      // Save to Firestore
      final memoryService = ref.read(memoryServiceProvider);
      final newMemory = MemoryModel(
        id: const Uuid().v4(),
        title: titleController.text.trim(),
        mediaUrl: imageUrl,
        category: MemoryCategory.photo,
        date: DateTime.now(),
        colorIndex: DateTime.now().millisecond % _memoryColors.length,
      );

      await memoryService.addMemory(
        memory: newMemory,
        userId: user.id,
        partnerId: user.partnerId!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إضافة الذكرى بنجاح!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final streamData = ref.watch(memoriesStreamProvider);
    final memories = ref.watch(filteredMemoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppColors.background.withOpacity(0.95),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'ألبوم الذكريات 📸',
                style: GoogleFonts.tajawal(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              centerTitle: true,
            ),
          ),

          // Filters
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    _filters.length,
                    (i) => GestureDetector(
                      onTap: () => _onFilterTap(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(left: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: _selectedFilter == i ? AppColors.primaryGradient : null,
                          color: _selectedFilter == i ? null : AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedFilter == i
                                ? Colors.transparent
                                : AppColors.divider,
                          ),
                        ),
                        child: Text(
                          _filters[i],
                          style: GoogleFonts.tajawal(
                            color: _selectedFilter == i
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: _selectedFilter == i
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Stats Row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${memories.length} ذكرى',
                    style: GoogleFonts.tajawal(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Memory Grid
          streamData.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(child: Text('خطأ في جلب الذكريات: $err', style: const TextStyle(color: Colors.white))),
            ),
            data: (_) => memories.isEmpty
                ? SliverFillRemaining(
                    child: EmptyStateWidget(
                      icon: Icons.photo_library_rounded,
                      title: 'لا توجد ذكريات بعد',
                      subtitle: 'أضيفوا أول ذكرى معاً ❤️',
                      actionText: 'إضافة ذكرى',
                      action: _uploadNewMemory,
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.all(4),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final memory = memories[index];
                          return GestureDetector(
                            onTap: () {
                              ref.read(selectedMemoryProvider.notifier).state = memory;
                              context.push('/memory-detail');
                            },
                            child: Hero(
                              tag: 'memory_${memory.id}',
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(_memoryColors[memory.colorIndex % _memoryColors.length]),
                                  borderRadius: BorderRadius.circular(12),
                                  image: memory.mediaUrl != null
                                      ? DecorationImage(
                                          image: getSmartImageProvider(memory.mediaUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Gradient overlay
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(12),
                                            bottomRight: Radius.circular(12),
                                          ),
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.8),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              memory.title,
                                              style: GoogleFonts.tajawal(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '${memory.date.year}/${memory.date.month}/${memory.date.day}',
                                              style: GoogleFonts.tajawal(
                                                color: Colors.white70,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: Duration(milliseconds: index * 50));
                        },
                        childCount: memories.length,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                    ),
                  ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: _isUploading
          ? const FloatingActionButton(
              onPressed: null,
              backgroundColor: AppColors.card,
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                elevation: 0,
                onPressed: _uploadNewMemory,
                child: const Icon(Icons.add_photo_alternate_rounded, color: Colors.white),
              ),
            ),
    );
  }
}
