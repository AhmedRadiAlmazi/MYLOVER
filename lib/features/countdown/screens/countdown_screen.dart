import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/models/app_models.dart';
import '../../calendar/providers/calendar_provider.dart';
import '../../calendar/services/calendar_service.dart';
import '../../auth/providers/auth_provider.dart';

class CountdownScreen extends ConsumerStatefulWidget {
  const CountdownScreen({super.key});

  @override
  ConsumerState<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends ConsumerState<CountdownScreen> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    bool isSaving = false;
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'إضافة مناسبة جديدة',
            style: GoogleFonts.tajawal(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: GoogleFonts.tajawal(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'اسم المناسبة (مثل: ذكرى زواجنا)',
                  hintStyle: GoogleFonts.tajawal(color: AppColors.textHint),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                  );
                  if (pickedDate != null) {
                    setStateDialog(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        'التاريخ: ${selectedDate.year}/${selectedDate.month}/${selectedDate.day}',
                        style: GoogleFonts.tajawal(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: Text('إلغاء', style: GoogleFonts.tajawal(color: AppColors.textHint)),
            ),
            isSaving
                ? const CircularProgressIndicator(color: AppColors.primary)
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: () async {
                      if (titleController.text.trim().isEmpty) return;
                      setStateDialog(() => isSaving = true);
                      
                      try {
                        final user = ref.read(currentUserProvider).value;
                        if (user != null && user.partnerId != null) {
                          final newEvent = EventModel(
                            id: const Uuid().v4(),
                            title: titleController.text.trim(),
                            date: selectedDate,
                            type: 'special',
                            icon: Icons.favorite_rounded,
                            isRecurring: true,
                          );
                          
                          final service = ref.read(calendarServiceProvider);
                          await service.addEvent(event: newEvent, userId: user.id, partnerId: user.partnerId!);
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

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsStreamProvider);

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
            onPressed: _showAddEventDialog,
          ),
        ],
      ),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('حدث خطأ في تحميل المناسبات', style: GoogleFonts.tajawal(color: Colors.white))),
        data: (events) {
          final upcomingEvents = events
              .where((e) => e.date.isAfter(_now))
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));

          if (upcomingEvents.isEmpty) {
            return Center(
              child: EmptyStateWidget(
                icon: Icons.alarm_off_rounded,
                title: 'لا توجد مناسبات قادمة',
                subtitle: 'أضف أول مناسبة لبدء العد التنازلي',
                actionText: 'إضافة مناسبة',
                action: _showAddEventDialog,
              ),
            );
          }

          final mainEvent = upcomingEvents.first;
          final otherEvents = upcomingEvents.skip(1).toList();

          final diff = mainEvent.date.difference(_now);
          final remaining = diff.isNegative ? Duration.zero : diff;

          final days = remaining.inDays;
          final hours = remaining.inHours.remainder(24);
          final minutes = remaining.inMinutes.remainder(60);
          final seconds = remaining.inSeconds.remainder(60);

          return SingleChildScrollView(
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
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withOpacity(0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(mainEvent.icon, size: 60, color: Colors.white).animate().scale(),
                        const SizedBox(height: 12),
                        Text(mainEvent.title, style: GoogleFonts.tajawal(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          '${mainEvent.date.year}/${mainEvent.date.month}/${mainEvent.date.day}',
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
                  if (otherEvents.isNotEmpty) ...[
                    SectionHeader(
                      title: 'مناسبات قادمة أخرى',
                      actionText: 'إضافة',
                      action: _showAddEventDialog,
                    ),
                    const SizedBox(height: 16),
                    ...otherEvents.asMap().entries.map((e) {
                      final daysLeft = e.value.date.difference(_now).inDays;
                      return _EventCountdown(
                        icon: e.value.icon,
                        title: e.value.title,
                        daysLeft: daysLeft,
                      ).animate().slideX(
                        delay: Duration(milliseconds: e.key * 80 + 200),
                      ).fadeIn(
                        delay: Duration(milliseconds: e.key * 80 + 200),
                      );
                    }),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
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
