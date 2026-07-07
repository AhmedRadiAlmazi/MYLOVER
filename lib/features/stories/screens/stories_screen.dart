import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  final List<StoryItem> _stories = [
    const StoryItem(Icons.menu_book_rounded, 'قصة حبنا', 'منذ البداية وحتى الآن...', '2 يناير 2024', 5),
    const StoryItem(Icons.star_rounded, 'رحلة إسطنبول', 'قصة رحلتنا الأولى معاً...', '25 أغسطس 2023', 5),
    const StoryItem(Icons.sentiment_satisfied_rounded, 'لحظة اليوم الأول', 'كيف تقابلنا للمرة الأولى...', '15 يونيو 2023', 3),
    const StoryItem(Icons.chat_bubble_rounded, 'أحلامنا المشتركة', 'كل الأحلام التي نحلم بها معاً...', '10 مارس 2024', 4),
  ];

  void _showAddStoryDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    IconData selectedIcon = Icons.favorite_rounded;
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'إنشاء قصة جديدة',
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
                    hintText: 'عنوان القصة (مثال: رحلة العيد)',
                    hintStyle: GoogleFonts.tajawal(color: AppColors.textHint),
                    filled: true,
                    fillColor: AppColors.card,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  style: GoogleFonts.tajawal(color: AppColors.textPrimary),
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'وصف قصير للقصة...',
                    hintStyle: GoogleFonts.tajawal(color: AppColors.textHint),
                    filled: true,
                    fillColor: AppColors.card,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                Text('اختر أيقونة القصة:', style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icons.favorite_rounded,
                    Icons.star_rounded,
                    Icons.flight_takeoff_rounded,
                    Icons.cake_rounded,
                    Icons.camera_alt_rounded
                  ].map((icon) {
                    final isSelected = selectedIcon == icon;
                    return GestureDetector(
                      onTap: () => setStateDialog(() => selectedIcon = icon),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
                          border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 28),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء', style: GoogleFonts.tajawal(color: AppColors.textHint)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                setState(() {
                  _stories.insert(
                    0,
                    StoryItem(
                      selectedIcon,
                      titleController.text.trim(),
                      descController.text.trim().isEmpty ? 'لا يوجد وصف...' : descController.text.trim(),
                      'اليوم',
                      1,
                    ),
                  );
                });
                Navigator.pop(context);
              },
              child: Text('إنشاء', style: GoogleFonts.tajawal()),
            ),
          ],
        ),
      ),
    );
  }

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
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary, size: 28),
            onPressed: _showAddStoryDialog,
          ),
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (ctx) => StoryViewerScreen(story: story)),
                  );
                },
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
          onPressed: _showAddStoryDialog,
          child: const Icon(Icons.create_rounded, color: Colors.white),
        ),
      ),
    );
  }
}

class StoryViewerScreen extends StatefulWidget {
  final StoryItem story;
  const StoryViewerScreen({super.key, required this.story});

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  int _currentPage = 0;
  late PageController _pageController;
  Timer? _timer;
  double _progress = 0.0;

  final Map<String, List<String>> _storyPages = {
    'قصة حبنا': [
      'التقينا في 15 يونيو 2023 وكانت صدفة جميلة جداً.',
      'تحدثنا طويلاً عن اهتماماتنا المشتركة، وشعرت أنني أعرفك منذ سنوات.',
      'قررنا أن نكون معاً في رحلة الحياة.',
      'كل يوم معك هو بداية لقصة جديدة.',
      'أحبك اليوم أكثر من الأمس وأقل من الغد.'
    ],
    'رحلة إسطنبول': [
      'وصلنا لإسطنبول والجو كان رائعاً.',
      'ركبنا السفينة في مضيق البوسفور والتقطنا أجمل الصور.',
      'زرنا معالم المدينة التاريخية مثل آيا صوفيا والجامع الأزرق.',
      'تناولنا الغداء في مطعم مطل على البحر.',
      'كانت رحلة العمر التي لن أنساها أبداً.'
    ],
    'لحظة اليوم الأول': [
      'كيف تقابلنا للمرة الأولى في المقهى الهادئ.',
      'كنت خجولاً جداً في البداية ولكن سرعان ما تآلفنا.',
      'ابتسامتك الأولى لا تزال مطبوعة في قلبي.'
    ],
    'أحلامنا المشتركة': [
      'أن نبني بيتاً صغيراً دافئاً مليئاً بالورود والكتب.',
      'أن نسافر معاً حول العالم ونكتشف أماكن جديدة.',
      'أن نكبر معاً ونروي قصتنا لأحفادنا.',
      'أن ندعم بعضنا البعض في كل خطوة ومحنة.'
    ]
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _progress = 0.0;
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
      setState(() {
        if (_progress < 1.0) {
          _progress += 0.01;
        } else {
          _timer?.cancel();
          _nextPage();
        }
      });
    });
  }

  void _nextPage() {
    final pagesList = _storyPages[widget.story.title] ?? ['مساحة فارغة للمحتوى والذكريات القادمة مع الشريك...'];
    if (_currentPage < pagesList.length - 1) {
      setState(() {
        _currentPage++;
      });
      _pageController.animateToPage(_currentPage, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      _startTimer();
    } else {
      Navigator.pop(context);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _pageController.animateToPage(_currentPage, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pagesList = _storyPages[widget.story.title] ?? ['مساحة فارغة للمحتوى والذكريات القادمة مع الشريك...'];
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Story pages
          GestureDetector(
            onTapDown: (details) {
              final screenWidth = MediaQuery.of(context).size.width;
              if (details.globalPosition.dx < screenWidth / 3) {
                _prevPage();
              } else {
                _nextPage();
              }
            },
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pagesList.length,
              itemBuilder: (context, idx) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(widget.story.icon, size: 80, color: AppColors.primary).animate().scale(duration: 500.ms),
                        const SizedBox(height: 40),
                        Text(
                          pagesList[idx],
                          style: GoogleFonts.tajawal(color: Colors.white, fontSize: 22, height: 1.6, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(duration: 500.ms),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Progress bars
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: List.generate(pagesList.length, (index) {
                  double val = 0.0;
                  if (index < _currentPage) {
                    val = 1.0;
                  } else if (index == _currentPage) {
                    val = _progress;
                  }
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: val,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          
          // Top Bar info
          Positioned(
            top: 76,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(widget.story.icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      widget.story.title,
                      style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StoryItem {
  final IconData icon;
  final String title;
  final String preview;
  final String date;
  final int pages;
  const StoryItem(this.icon, this.title, this.preview, this.date, this.pages);
}
