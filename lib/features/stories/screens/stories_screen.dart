import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key});

  final List<_Story> _stories = const [
    _Story(Icons.menu_book_rounded, 'قصة حبنا', 'منذ البداية وحتى الآن...', '2 يناير 2024', 5),
    _Story(Icons.star_rounded, 'رحلة إسطنبول', 'قصة رحلتنا الأولى معاً...', '25 أغسطس 2023', 12),
    _Story(Icons.sentiment_satisfied_rounded, 'لحظة اليوم الأول', 'كيف تقابلنا للمرة الأولى...', '15 يونيو 2023', 3),
    _Story(Icons.chat_bubble_rounded, 'أحلامنا المشتركة', 'كل الأحلام التي نحلم بها معاً...', '10 مارس 2024', 8),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withOpacity(0.95),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary), onPressed: () => context.pop()),
        title: Text('قصصنا معاً', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 20)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.add_rounded, color: AppColors.primary, size: 28), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _stories.length,
        itemBuilder: (context, i) {
          final story = _stories[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: i % 2 == 0 ? AppColors.primaryGradient : AppColors.roseGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 5))],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                        child: Center(child: Icon(story.icon, size: 32, color: Colors.white)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(story.title, style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(story.preview, style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 8),
                          Row(children: [
                            Text(story.date, style: GoogleFonts.tajawal(color: Colors.white60, fontSize: 11)),
                            const SizedBox(width: 16),
                            Text('${story.pages} صفحة', style: GoogleFonts.tajawal(color: Colors.white60, fontSize: 11)),
                          ]),
                        ]),
                      ),
                      const Icon(Icons.arrow_back_ios_rounded, color: Colors.white60, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ).animate().slideX(begin: i.isEven ? -0.2 : 0.2, delay: Duration(milliseconds: i * 100)).fadeIn(delay: Duration(milliseconds: i * 100));
        },
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () {},
          child: const Icon(Icons.create_rounded, color: Colors.white),
        ),
      ),
    );
  }
}

class _Story {
  final IconData icon;
  final String title;
  final String preview;
  final String date;
  final int pages;
  const _Story(this.icon, this.title, this.preview, this.date, this.pages);
}
