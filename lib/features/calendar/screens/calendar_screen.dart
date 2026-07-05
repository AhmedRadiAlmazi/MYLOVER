import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/app_models.dart' hide currentUserProvider;
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/calendar_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
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
          content: TextField(
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
                            date: _selectedDay ?? _focusedDay,
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
    final eventsMap = ref.watch(calendarEventsProvider);
    
    List<EventModel> _getEventsForDay(DateTime day) {
      final key = DateTime(day.year, day.month, day.day);
      return eventsMap[key] ?? [];
    }

    final _selectedEvents = _getEventsForDay(_selectedDay ?? _focusedDay);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withOpacity(0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'تقويم المناسبات 📅',
          style: GoogleFonts.tajawal(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary, size: 28),
            onPressed: _showAddEventDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TableCalendar<EventModel>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.saturday,
              locale: 'ar',
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                todayDecoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: GoogleFonts.tajawal(color: AppColors.textPrimary),
                weekendTextStyle: GoogleFonts.tajawal(color: AppColors.secondary),
                outsideTextStyle: GoogleFonts.tajawal(color: AppColors.textHint),
                todayTextStyle: GoogleFonts.tajawal(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                selectedTextStyle: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold),
                cellMargin: const EdgeInsets.all(6),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                titleTextStyle: GoogleFonts.tajawal(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                formatButtonDecoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
                formatButtonTextStyle: GoogleFonts.tajawal(color: AppColors.primary, fontSize: 12),
                leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.primary),
                rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.primary),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 12),
                weekendStyle: GoogleFonts.tajawal(color: AppColors.secondary, fontSize: 12),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) => setState(() => _calendarFormat = format),
              onPageChanged: (focusedDay) => _focusedDay = focusedDay,
            ),
          ),

          // Events for selected day
          Expanded(
            child: _selectedEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('📆', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد مناسبات هذا اليوم',
                          style: GoogleFonts.tajawal(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _selectedEvents.length,
                    itemBuilder: (context, index) {
                      final event = _selectedEvents[index];
                      return _buildEventCard(event, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(EventModel event, int index) {
    final Map<String, Color> typeColors = {
      'anniversary': AppColors.secondary,
      'birthday': AppColors.accent,
      'special': AppColors.primary,
      'travel': AppColors.success,
    };
    final color = typeColors[event.type] ?? AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(event.icon, color: color, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 15,
                  ),
                ),
                if (event.note != null)
                  Text(
                    event.note!,
                    style: GoogleFonts.tajawal(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (event.isRecurring)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'سنوي',
                style: GoogleFonts.tajawal(color: color, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    ).animate().slideX(delay: Duration(milliseconds: index * 80)).fadeIn(delay: Duration(milliseconds: index * 80));
  }
}
