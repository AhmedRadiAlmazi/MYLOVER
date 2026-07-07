import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/models/app_models.dart';
import '../providers/diary_provider.dart';
import '../../../core/services/storage_service.dart';
import '../../auth/providers/auth_provider.dart';

class DiaryEntryScreen extends ConsumerStatefulWidget {
  const DiaryEntryScreen({super.key, this.entry});
  final DiaryModel? entry;

  @override
  ConsumerState<DiaryEntryScreen> createState() => _DiaryEntryScreenState();
}

class _DiaryEntryScreenState extends ConsumerState<DiaryEntryScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  IconData _selectedMood = Icons.sentiment_very_satisfied_rounded;
  bool _isShared = false;
  bool _isSaving = false;
  File? _imageFile;
  String? _existingImageUrl;

  final List<IconData> _moods = [
    Icons.sentiment_very_satisfied_rounded,
    Icons.sentiment_satisfied_alt_rounded,
    Icons.sentiment_dissatisfied_rounded,
    Icons.mood_bad_rounded,
    Icons.bedtime_rounded,
    Icons.favorite_rounded,
    Icons.nightlight_round,
    Icons.star_rounded,
    Icons.sentiment_neutral_rounded,
    Icons.favorite_border_rounded,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title;
      _bodyController.text = widget.entry!.body;
      _selectedMood = widget.entry!.moodIcon;
      _isShared = widget.entry!.isShared;
      _existingImageUrl = widget.entry!.imageUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  void _save() async {
    if (_titleController.text.trim().isEmpty || _bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء إدخال العنوان والمحتوى', style: GoogleFonts.tajawal()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null || currentUser.partnerId == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في بيانات المستخدم', style: GoogleFonts.tajawal()), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      String? imageUrl = _existingImageUrl;
      if (_imageFile != null) {
        final storageService = ref.read(storageServiceProvider);
        imageUrl = await storageService.uploadFile(_imageFile!, 'diary_images');
      }

      final diaryService = ref.read(diaryServiceProvider);
      final newEntry = DiaryModel(
        id: widget.entry?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        mood: 'mood',
        moodIconCodePoint: _selectedMood.codePoint,
        date: widget.entry?.date ?? DateTime.now(),
        authorName: widget.entry?.authorName ?? currentUser.name,
        isShared: _isShared,
        imageUrl: imageUrl,
      );

      await diaryService.addDiaryEntry(
        entry: newEntry,
        userId: currentUser.id,
        partnerId: currentUser.partnerId!,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ يومياتك بنجاح ✓', style: GoogleFonts.tajawal()),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء الحفظ: $e', style: GoogleFonts.tajawal()),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;
    final isAuthor = widget.entry == null || widget.entry!.authorName == currentUser?.name;
    final today = DateFormat('EEEE، d MMMM yyyy', 'ar').format(widget.entry?.date ?? DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withOpacity(0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isAuthor ? (widget.entry == null ? 'اكتب يومياتك' : 'تعديل اليوميات') : 'عرض اليوميات',
          style: GoogleFonts.tajawal(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: isAuthor
            ? [
                GradientButton(
                  text: 'حفظ',
                  onPressed: _save,
                  isLoading: _isSaving,
                  width: 80,
                  height: 38,
                  borderRadius: 12,
                ),
                const SizedBox(width: 12),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date display
              Text(
                today,
                style: GoogleFonts.tajawal(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 20),

              // Mood Selector
              Text(
                'كيف حالك اليوم؟',
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ).animate().slideY().fadeIn(),
              const SizedBox(height: 12),
              SizedBox(
                height: 56,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _moods.length,
                  itemBuilder: (context, i) {
                    final mood = _moods[i];
                    final isSelected = mood == _selectedMood;
                    return GestureDetector(
                      onTap: isAuthor ? () => setState(() => _selectedMood = mood) : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(left: 8),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.2)
                              : AppColors.card,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.divider,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            mood,
                            size: 28,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ).animate().slideX(delay: 100.ms).fadeIn(delay: 100.ms),
              const SizedBox(height: 24),

              // Title field
              TextField(
                controller: _titleController,
                readOnly: !isAuthor,
                style: GoogleFonts.tajawal(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'عنوان يومياتك...',
                  hintStyle: GoogleFonts.tajawal(
                    color: AppColors.textHint,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ).animate().fadeIn(delay: 150.ms),

              const Divider(color: AppColors.divider, thickness: 1),
              const SizedBox(height: 12),

              // Body field
              TextField(
                controller: _bodyController,
                readOnly: !isAuthor,
                maxLines: null,
                minLines: 8,
                keyboardType: TextInputType.multiline,
                style: GoogleFonts.tajawal(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.8,
                ),
                decoration: InputDecoration(
                  hintText: 'ماذا حدث اليوم؟ كيف تشعر؟ ماذا تريد؟\n\nاكتب هنا بحرية...',
                  hintStyle: GoogleFonts.tajawal(
                    color: AppColors.textHint,
                    fontSize: 15,
                    height: 1.8,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 24),

              // Sharing toggle
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    const Icon(Icons.share_outlined, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مشاركة مع شريكي',
                            style: GoogleFonts.tajawal(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'سيتمكن شريكك من رؤية هذه اليوميات',
                            style: GoogleFonts.tajawal(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isShared,
                      onChanged: isAuthor ? (val) => setState(() => _isShared = val) : null,
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ).animate().slideY(delay: 300.ms).fadeIn(delay: 300.ms),

              const SizedBox(height: 16),

              // Image attachment preview and button
              if (_imageFile != null) ...[
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_imageFile!, height: 150, width: double.infinity, fit: BoxFit.cover),
                    ),
                    if (isAuthor)
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.white, size: 28),
                        onPressed: () => setState(() => _imageFile = null),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ] else if (_existingImageUrl != null) ...[
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SmartImage(
                        imageUrl: _existingImageUrl!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (isAuthor)
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.white, size: 28),
                        onPressed: () => setState(() => _existingImageUrl = null),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              
              if (isAuthor)
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: Text((_imageFile == null && _existingImageUrl == null) ? 'إرفاق صورة' : 'تغيير الصورة', style: GoogleFonts.tajawal()),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ).animate().fadeIn(delay: 350.ms),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

