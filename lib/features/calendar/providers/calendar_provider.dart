import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/app_models.dart';
import '../../../features/calendar/services/calendar_service.dart';
import '../../auth/providers/auth_provider.dart';

final calendarServiceProvider = Provider<CalendarService>((ref) => CalendarService());

// جلب المناسبات كبث حي من Firebase
final eventsStreamProvider = StreamProvider<List<EventModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null || user.partnerId == null || user.partnerId!.isEmpty) {
    return Stream.value([]);
  }
  
  final service = ref.watch(calendarServiceProvider);
  return service.getEventsStream(user.id, user.partnerId!);
});

// تحويل القائمة المستلمة من Firebase إلى Map لسهولة استخدامها مع TableCalendar
final calendarEventsProvider = Provider<Map<DateTime, List<EventModel>>>((ref) {
  final eventsAsync = ref.watch(eventsStreamProvider);
  final eventsList = eventsAsync.value ?? [];
  
  final Map<DateTime, List<EventModel>> map = {};
  for (final e in eventsList) {
    // Normalization ليكون المفتاح عبارة عن تاريخ بدون وقت
    final key = DateTime(e.date.year, e.date.month, e.date.day);
    map[key] = [...(map[key] ?? []), e];
  }
  
  return map;
});

