import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Mock Love Quotes ─────────────────────────────────────────────────────────

const _loveQuotes = <String>[
  'أنتِ الشمس التي تُضيء حياتي في كل يوم جديد 🌅',
  'في عيونكِ وجدتُ وطناً لا أريد أن أغادره أبداً 💙',
  'الحب ليس مجرد كلمات، بل هو كل لحظة نقضيها معاً 🌸',
  'أنتِ دليلي حين أضيع وأملي حين أيأس 🕊️',
  'منذ أن دخلتِ حياتي، أصبح كل شيء له معنى أجمل 🌹',
  'لو تُحسب النعم، أنتِ في أولها وآخرها ✨',
  'أحبكِ بقدر ما تتسع قلوب العالمين ❤️',
  'أنتِ الأغنية التي يُرددها قلبي في كل لحظة صمت 🎵',
  'معكِ فقط أشعر أن الحياة تستحق كل شيء 🌙',
  'كل يوم أقضيه معكِ هو يوم يُضاف إلى أجمل أيام عمري 🌺',
];

// ─── Providers ────────────────────────────────────────────────────────────────

/// Number of days the couple has been together (mock: 547).
final dayCounterProvider = Provider<int>((ref) {
  // In production, compute from stored relationshipStart date.
  const startDate = '2024-01-15';
  final start = DateTime.parse(startDate);
  final now = DateTime.now();
  return now.difference(start).inDays;
});

/// A random Arabic love quote refreshed each session.
final dailyQuoteProvider = Provider<String>((ref) {
  final idx = Random().nextInt(_loveQuotes.length);
  return _loveQuotes[idx];
});

/// Whether the partner is currently online (mock default: true).
final partnerStatusProvider = StateProvider<bool>((ref) => true);

/// Quick-action items for the home grid.
final quickActionsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {
      'emoji': '💬',
      'label': 'الدردشة',
      'route': '/chat',
      'gradient': const [Color(0xFF8B3FD9), Color(0xFFFF6B9D)],
    },
    {
      'emoji': '📸',
      'label': 'الذكريات',
      'route': '/memories',
      'gradient': const [Color(0xFFFF6B9D), Color(0xFFFF9CBB)],
    },
    {
      'emoji': '📔',
      'label': 'اليوميات',
      'route': '/diary',
      'gradient': const [Color(0xFF6A3FD9), Color(0xFF8B3FD9)],
    },
    {
      'emoji': '📅',
      'label': 'التقويم',
      'route': '/calendar',
      'gradient': const [Color(0xFF3F5FD9), Color(0xFF6A3FD9)],
    },
    {
      'emoji': '🎁',
      'label': 'المفاجآت',
      'route': '/surprise-box',
      'gradient': const [Color(0xFFFFD700), Color(0xFFFFB300)],
    },
    {
      'emoji': '🎮',
      'label': 'الألعاب',
      'route': '/games',
      'gradient': const [Color(0xFF00BCD4), Color(0xFF0097A7)],
    },
    {
      'emoji': '🤖',
      'label': 'المساعد الذكي',
      'route': '/ai',
      'gradient': const [Color(0xFF4CAF50), Color(0xFF388E3C)],
    },
    {
      'emoji': '📊',
      'label': 'الإحصائيات',
      'route': '/stats',
      'gradient': const [Color(0xFFFF5722), Color(0xFFE64A19)],
    },
  ];
});

// Needed for Color usage in pure Dart provider file
// ignore: avoid_classes_with_only_static_members
class Color {
  const Color(this.value);
  final int value;
}
