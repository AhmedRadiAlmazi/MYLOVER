import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  
  // Mock upcoming event
  final DateTime _eventDate = DateTime.now().add(const Duration(days: 14, hours: 6, minutes: 33, seconds: 12));
  final String _eventTitle = 'ذكرانا السنوية';
  final IconData _eventIcon = Icons.diamond_rounded;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final diff = _eventDate.difference(DateTime.now());
      setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final days = _remaining.inDays;
    final hours = _remaining.inHours.remainder(24);
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withOpacity(0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('العد التنازلي', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 20)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Main countdown card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(color: AppColors.primaryDark.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 10))],
                ),
                child: Column(
                  children: [
                    Icon(_eventIcon, size: 60, color: Colors.white).animate().scale(),
                    const SizedBox(height: 12),
                    Text(_eventTitle, style: GoogleFonts.tajawal(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      '${_eventDate.year}/${_eventDate.month}/${_eventDate.day}',
                      style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 32),
                    // Time display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _TimeUnit(value: _twoDigits(days), label: 'يوم'),
                        _Divider(),
                        _TimeUnit(value: _twoDigits(hours), label: 'ساعة'),
                        _Divider(),
                        _TimeUnit(value: _twoDigits(minutes), label: 'دقيقة'),
                        _Divider(),
                        _TimeUnit(value: _twoDigits(seconds), label: 'ثانية'),
                      ],
                    ),
                  ],
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack).fadeIn(),

              const SizedBox(height: 32),

              // Other events
              SectionHeader(title: 'مناسبات قادمة أخرى', actionText: 'إضافة', action: () {}),
              const SizedBox(height: 16),

              ...[
                _EventCountdown(icon: Icons.cake_rounded, title: 'عيد ميلادك', daysLeft: 67),
                _EventCountdown(icon: Icons.celebration_rounded, title: 'عيد ميلاد شريكي', daysLeft: 142),
                _EventCountdown(icon: Icons.flight_takeoff_rounded, title: 'رحلة الصيف', daysLeft: 38),
              ].asMap().entries.map((e) =>
                e.value.animate().slideX(delay: Duration(milliseconds: e.key * 80 + 200)).fadeIn(delay: Duration(milliseconds: e.key * 80 + 200))
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeUnit extends StatelessWidget {
  const _TimeUnit({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(value, style: GoogleFonts.tajawal(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      child: Text(':', style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 28, fontWeight: FontWeight.bold)),
    );
  }
}

class _EventCountdown extends StatelessWidget {
  const _EventCountdown({required this.icon, required this.title, required this.daysLeft});
  final IconData icon;
  final String title;
  final int daysLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: GoogleFonts.tajawal(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'بعد $daysLeft يوم',
              style: GoogleFonts.tajawal(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
