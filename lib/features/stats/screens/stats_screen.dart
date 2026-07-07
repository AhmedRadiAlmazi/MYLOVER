import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models/app_models.dart';
import '../../chat/providers/chat_provider.dart';
import '../../memories/providers/memories_provider.dart';
import '../../diary/providers/diary_provider.dart';
import '../../auth/providers/auth_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // 1. Data Fetching
    final currentUser = ref.watch(currentUserProvider).value;
    
    final int daysTogether = currentUser?.relationshipStart != null 
        ? DateTime.now().difference(currentUser!.relationshipStart!).inDays 
        : 0;

    final messagesAsync = ref.watch(messagesProvider);
    final memoriesAsync = ref.watch(memoriesStreamProvider);
    final diariesAsync = ref.watch(diaryEntriesProvider);

    final int messagesCount = messagesAsync.value?.length ?? 0;
    
    final memories = memoriesAsync.value ?? [];
    final int photosCount = memories.where((m) => m.category == MemoryCategory.photo).length;
    final int videosCount = memories.where((m) => m.category == MemoryCategory.video).length;
    final int memoriesCount = memories.length;
    
    final int diariesCount = diariesAsync.value?.length ?? 0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'إحصائياتنا', 
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: colorScheme.onSurface, fontSize: 20)
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _StatCard(value: messagesCount, label: 'الرسائل', icon: Icons.chat_bubble_rounded, color: colorScheme.primary),
                _StatCard(value: photosCount, label: 'الصور', icon: Icons.photo_camera_rounded, color: colorScheme.secondary),
                _StatCard(value: videosCount, label: 'الفيديوهات', icon: Icons.movie_creation_rounded, color: colorScheme.tertiary),
                _StatCard(value: memoriesCount, label: 'الذكريات', icon: Icons.favorite_rounded, color: const Color(0xFFFF4081)),
                _StatCard(value: daysTogether, label: 'يوم معاً', icon: Icons.calendar_today_rounded, color: colorScheme.primary),
                _StatCard(value: diariesCount, label: 'اليوميات', icon: Icons.menu_book_rounded, color: colorScheme.secondary),
              ],
            ),

            const SizedBox(height: 32),

            // Messages per month chart
            Text(
              'الرسائل في الأشهر الأخيرة',
              style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ).animate().fadeIn(),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: [
                    _makeBar(0, max(5, messagesCount * 0.2), colorScheme.primary),
                    _makeBar(1, max(10, messagesCount * 0.4), colorScheme.secondary),
                    _makeBar(2, max(8, messagesCount * 0.3), colorScheme.primary),
                    _makeBar(3, max(15, messagesCount * 0.6), colorScheme.secondary),
                    _makeBar(4, max(12, messagesCount * 0.5), colorScheme.primary),
                    _makeBar(5, max(20, messagesCount * 0.8), colorScheme.tertiary),
                  ],
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(color: theme.dividerColor, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو'];
                          return Text(months[v.toInt()], style: GoogleFonts.tajawal(color: theme.textTheme.bodySmall?.color, fontSize: 9));
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ).animate().slideY(delay: 200.ms).fadeIn(delay: 200.ms),

            const SizedBox(height: 32),

            // Pie chart for media types
            Text(
              'توزيع الوسائط',
              style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    height: 140,
                    width: 140,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(value: max(1, photosCount.toDouble()), color: colorScheme.primary, title: '$photosCount\nصور', radius: 55, titleStyle: GoogleFonts.tajawal(color: colorScheme.onPrimary, fontSize: 10, fontWeight: FontWeight.bold)),
                          PieChartSectionData(value: max(1, videosCount.toDouble()), color: colorScheme.secondary, title: '$videosCount\nفيديو', radius: 55, titleStyle: GoogleFonts.tajawal(color: colorScheme.onSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                          PieChartSectionData(value: max(1, memoriesCount.toDouble()), color: colorScheme.tertiary, title: '$memoriesCount\nذكريات', radius: 55, titleStyle: GoogleFonts.tajawal(color: colorScheme.onTertiary, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                        sectionsSpace: 4,
                        centerSpaceRadius: 15,
                      ),
                    ),
                  ).animate().scale(delay: 350.ms).fadeIn(delay: 350.ms),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LegendItem(color: colorScheme.primary, label: 'الصور', count: photosCount),
                        const SizedBox(height: 12),
                        _LegendItem(color: colorScheme.secondary, label: 'الفيديو', count: videosCount),
                        const SizedBox(height: 12),
                        _LegendItem(color: colorScheme.tertiary, label: 'الذكريات', count: memoriesCount),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Most used words
            Text(
              'أكثر الكلمات استخداماً',
              style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _WordChip('أحبك', 234, colorScheme.secondary),
                _WordChip('اشتقت', 189, colorScheme.primary),
                _WordChip('حبيبي', 156, colorScheme.tertiary),
                _WordChip('ماذا تفعل', 134, Colors.green),
                _WordChip('صباح الخير', 112, Colors.blue),
                _WordChip('مساء النور', 98, colorScheme.primary),
                _WordChip('❤️', 289, const Color(0xFFFF4081)),
              ],
            ).animate().slideY(delay: 450.ms).fadeIn(delay: 450.ms),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeBar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [BarChartRodData(toY: y, color: color, width: 18, borderRadius: BorderRadius.circular(6))],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label, required this.icon, required this.color});
  final int value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value.toDouble()),
            duration: const Duration(seconds: 2),
            builder: (context, val, child) {
              return Text(
                val.toInt().toString(),
                style: GoogleFonts.tajawal(
                  color: theme.colorScheme.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          Text(
            label,
            style: GoogleFonts.tajawal(
              color: theme.textTheme.bodySmall?.color,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label, required this.count});
  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text('$label ($count)', style: GoogleFonts.tajawal(color: theme.colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _WordChip extends StatelessWidget {
  const _WordChip(this.word, this.count, this.color);
  final String word;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(word, style: GoogleFonts.tajawal(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Text('$count', style: GoogleFonts.tajawal(color: color.withOpacity(0.8), fontSize: 11)),
        ],
      ),
    );
  }
}
