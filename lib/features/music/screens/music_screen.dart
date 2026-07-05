import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> with TickerProviderStateMixin {
  bool _isPlaying = false;
  int _currentSong = 0;
  late AnimationController _rotationController;

  final List<_Song> _songs = [
    _Song('Can\'t Help Falling In Love', 'Elvis Presley', '3:01', Icons.favorite_border_rounded),
    _Song('A Thousand Years', 'Christina Perri', '4:45', Icons.favorite_rounded),
    _Song('Perfect', 'Ed Sheeran', '4:23', Icons.volunteer_activism_rounded),
    _Song('Thinking Out Loud', 'Ed Sheeran', '4:41', Icons.favorite),
    _Song('All of Me', 'John Legend', '4:29', Icons.sentiment_very_satisfied_rounded),
    _Song('Marry You', 'Bruno Mars', '3:50', Icons.diamond_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    _rotationController.stop();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) _rotationController.repeat();
    else _rotationController.stop();
  }

  @override
  Widget build(BuildContext context) {
    final song = _songs[_currentSong];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withOpacity(0.95),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary), onPressed: () => context.pop()),
        title: Text('موسيقانا', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Album art
              RotationTransition(
                turns: _rotationController,
                child: Container(
                  width: 220, height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [BoxShadow(color: AppColors.primaryDark.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 10))],
                  ),
                  child: Center(child: Icon(song.icon, size: 80, color: Colors.white)),
                ),
              ).animate().scale().fadeIn(),
              const SizedBox(height: 24),

              // Song info
              Text(song.title, style: GoogleFonts.tajawal(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center).animate().fadeIn(),
              Text(song.artist, style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 14)).animate().fadeIn(),
              const SizedBox(height: 24),

              // Progress bar
              Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.divider,
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withOpacity(0.1),
                    ),
                    child: Slider(value: 0.4, onChanged: (_) {}),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1:12', style: GoogleFonts.tajawal(color: AppColors.textHint, fontSize: 12)),
                        Text(song.duration, style: GoogleFonts.tajawal(color: AppColors.textHint, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(icon: const Icon(Icons.shuffle_rounded, color: AppColors.textHint, size: 28), onPressed: () {}),
                  IconButton(
                    icon: const Icon(Icons.skip_previous_rounded, color: AppColors.textPrimary, size: 40),
                    onPressed: () => setState(() => _currentSong = (_currentSong - 1 + _songs.length) % _songs.length),
                  ),
                  Container(
                    width: 68, height: 68,
                    decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
                    child: IconButton(
                      icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 36),
                      onPressed: _togglePlay,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded, color: AppColors.textPrimary, size: 40),
                    onPressed: () => setState(() => _currentSong = (_currentSong + 1) % _songs.length),
                  ),
                  IconButton(icon: const Icon(Icons.repeat_rounded, color: AppColors.textHint, size: 28), onPressed: () {}),
                ],
              ),
              const SizedBox(height: 32),

              // Playlist
              SectionHeader(title: 'قائمة التشغيل'),
              const SizedBox(height: 12),
              ..._songs.asMap().entries.map((e) {
                final s = e.value;
                final isSelected = e.key == _currentSong;
                return GestureDetector(
                  onTap: () { setState(() { _currentSong = e.key; _isPlaying = true; }); _rotationController.repeat(); },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isSelected ? AppColors.primary.withOpacity(0.4) : AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        Icon(s.icon, size: 24, color: isSelected ? AppColors.primary : AppColors.textSecondary),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(s.title, style: GoogleFonts.tajawal(color: isSelected ? AppColors.primary : AppColors.textPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
                          Text(s.artist, style: GoogleFonts.tajawal(color: AppColors.textHint, fontSize: 11)),
                        ])),
                        Text(s.duration, style: GoogleFonts.tajawal(color: AppColors.textHint, fontSize: 12)),
                        if (isSelected) ...[const SizedBox(width: 8), Icon(Icons.bar_chart_rounded, color: AppColors.primary, size: 20)],
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _Song {
  final String title;
  final String artist;
  final String duration;
  final IconData icon;
  const _Song(this.title, this.artist, this.duration, this.icon);
}
