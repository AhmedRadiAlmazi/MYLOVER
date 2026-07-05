import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/models/app_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../providers/diary_provider.dart';

class DiaryScreen extends ConsumerStatefulWidget {
  const DiaryScreen({super.key});

  @override
  ConsumerState<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends ConsumerState<DiaryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = ['يومياتي', 'يومياته/يومياتها', 'مشتركة'];

  final Map<IconData, Color> _moodColors = {
    Icons.sentiment_very_satisfied_rounded: AppColors.success,
    Icons.sentiment_satisfied_alt_rounded: AppColors.secondary,
    Icons.sentiment_dissatisfied_rounded: const Color(0xFF4A90D9),
    Icons.mood_bad_rounded: AppColors.error,
    Icons.bedtime_rounded: const Color(0xFF9B59B6),
    Icons.favorite_rounded: AppColors.primary,
    Icons.nightlight_round: const Color(0xFF27AE60),
    Icons.star_rounded: AppColors.accent,
    Icons.sentiment_neutral_rounded: const Color(0xFF7F8C8D),
    Icons.favorite_border_rounded: AppColors.secondaryLight,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      ref.read(selectedDiaryCategoryProvider.notifier).state = _tabs[_tabController.index];
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entriesStream = ref.watch(diaryEntriesProvider);
    final entries = ref.watch(filteredDiaryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withOpacity(0.95),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'يومياتنا',
          style: GoogleFonts.tajawal(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.tajawal(fontSize: 13),
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: entriesStream.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, s) => Center(child: Text('حدث خطأ في جلب اليوميات', style: GoogleFonts.tajawal(color: Colors.white))),
        data: (_) => entries.isEmpty
            ? EmptyStateWidget(
                icon: Icons.menu_book_rounded,
                title: 'لا توجد يوميات بعد',
                subtitle: 'ابدأ بكتابة أول يوميات لك',
                actionText: 'اكتب الآن',
                action: () => context.push('/diary-entry'),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final moodColor = _moodColors[entry.moodIcon] ?? AppColors.primary;
                  return _buildDiaryCard(entry, moodColor, index);
                },
              ),
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () => context.push('/diary-entry'),
          child: const Icon(Icons.edit_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDiaryCard(DiaryModel entry, Color moodColor, int index) {
    return GestureDetector(
      onTap: () => context.push('/diary-entry'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border(
            right: BorderSide(color: moodColor, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(entry.moodIcon, size: 28, color: moodColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          DateFormat('EEEE، d MMMM yyyy', 'ar').format(entry.date),
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (entry.isShared)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'مشترك',
                        style: GoogleFonts.tajawal(
                          fontSize: 10,
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              if (entry.imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SmartImage(
                    imageUrl: entry.imageUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              // Body preview
              Text(
                entry.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              // Footer
              Row(
                children: [
                  Text(
                    'بقلم: ${entry.authorName}',
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: moodColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
                ],
              ),
            ],
          ),
        ),
      ).animate().slideY(begin: 0.2, delay: Duration(milliseconds: index * 80)).fadeIn(delay: Duration(milliseconds: index * 80)),
    );
  }
}
