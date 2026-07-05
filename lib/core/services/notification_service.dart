import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  final List<String> _loveQuotes = [
    "أنتِ أجمل ما حصل لي اليوم ❤️",
    "مجرد التفكير بك يجعلني أبتسم 😊",
    "لا شيء يعادل لحظة أقضيها معك  ",
    "وجودك بجانبي يكفيني عن العالم  ",
    "أحبك أكثر مما تتخيل 💕",
  ];

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle tap
      },
    );
  }

  Future<void> scheduleDailyLoveQuote() async {
    final now = tz.TZDateTime.now(tz.local);
    // Schedule for 10:00 AM every day
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final randomQuote = _loveQuotes[Random().nextInt(_loveQuotes.length)];

    await _notificationsPlugin.zonedSchedule(
      0, // ID for daily quote
      'تذكير حب 💌',
      randomQuote,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_quote_channel',
          'رسائل الحب اليومية',
          channelDescription: 'إشعارات عشوائية يومية لرسائل الحب',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at the same time
    );
  }

  Future<void> scheduleOccasionReminder(int id, String title, DateTime date) async {
    final tzDate = tz.TZDateTime.from(date, tz.local);
    
    // Remind 1 day before at 9:00 AM
    final reminderDate = tzDate.subtract(const Duration(days: 1)).add(const Duration(hours: 9));

    if (reminderDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _notificationsPlugin.zonedSchedule(
      id,
      'تذكير بمناسبة مهمة غداً! 🗓️',
      title,
      reminderDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'occasions_channel',
          'المناسبات',
          channelDescription: 'تنبيهات المناسبات الهامة',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
