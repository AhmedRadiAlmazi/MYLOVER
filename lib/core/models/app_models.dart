import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ── User Model ─────────────────────────────────────

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? partnerId;
  final String? pairingCode;
  final String? publicKey;
  final DateTime? relationshipStart;
  final bool isOnline;
  final DateTime? lastSeen;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.partnerId,
    this.pairingCode,
    this.publicKey,
    this.relationshipStart,
    this.isOnline = false,
    this.lastSeen,
  });

  factory UserModel.mock() => UserModel(
        id: 'user_1',
        name: 'محمد',
        email: 'user@test.com',
        partnerId: 'user_2',
        relationshipStart: DateTime(2023, 6, 15),
        isOnline: true,
      );

  factory UserModel.mockPartner() => UserModel(
        id: 'user_2',
        name: 'سارة',
        email: 'partner@test.com',
        partnerId: 'user_1',
        relationshipStart: DateTime(2023, 6, 15),
        isOnline: true,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'partnerId': partnerId,
        'pairingCode': pairingCode,
        'publicKey': publicKey,
        'relationshipStart': relationshipStart?.toIso8601String(),
        'isOnline': isOnline,
        'lastSeen': lastSeen?.toIso8601String(),
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        avatarUrl: map['avatarUrl'],
        partnerId: map['partnerId'],
        pairingCode: map['pairingCode'],
        publicKey: map['publicKey'],
        relationshipStart: map['relationshipStart'] != null
            ? DateTime.parse(map['relationshipStart'])
            : null,
        isOnline: map['isOnline'] ?? false,
        lastSeen: map['lastSeen'] != null
            ? DateTime.parse(map['lastSeen'])
            : null,
      );

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? partnerId,
    String? pairingCode,
    String? publicKey,
    DateTime? relationshipStart,
    bool? isOnline,
    DateTime? lastSeen,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        partnerId: partnerId ?? this.partnerId,
        pairingCode: pairingCode ?? this.pairingCode,
        publicKey: publicKey ?? this.publicKey,
        relationshipStart: relationshipStart ?? this.relationshipStart,
        isOnline: isOnline ?? this.isOnline,
        lastSeen: lastSeen ?? this.lastSeen,
      );
}

// ── Message Model ──────────────────────────────────

enum MessageType { text, image, video, audio, file, sticker, location }

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final MessageType type;
  final String? mediaUrl;
  final DateTime timestamp;
  final bool isRead;
  final bool isDeleted;
  final String? replyToId;
  final bool isPinned;
  final bool isEncrypted;

  final bool isPending;
  final String? thumbnailUrl;
  final String? localPath;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    this.type = MessageType.text,
    this.mediaUrl,
    required this.timestamp,
    this.isRead = false,
    this.isDeleted = false,
    this.replyToId,
    this.isPinned = false,
    this.isEncrypted = false,
    this.isPending = false,
    this.thumbnailUrl,
    this.localPath,
  });

  static List<MessageModel> get mockMessages => [
        MessageModel(
          id: '1',
          senderId: 'user_1',
          text: 'صباح الخير حبيبتي ❤️',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          isRead: true,
        ),
        MessageModel(
          id: '2',
          senderId: 'user_2',
          text: 'صباح النور يا قلبي 😊',
          timestamp: DateTime.now().subtract(const Duration(minutes: 28)),
          isRead: true,
        ),
        MessageModel(
          id: '3',
          senderId: 'user_1',
          text: 'كيف حالك اليوم؟',
          timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
          isRead: true,
        ),
        MessageModel(
          id: '4',
          senderId: 'user_2',
          text: 'بخير الحمد لله، اشتقت لك 🥺',
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
          isRead: true,
        ),
        MessageModel(
          id: '5',
          senderId: 'user_1',
          text: 'وأنا أكثر... متى نلتقي؟ 💕',
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
          isRead: true,
        ),
        MessageModel(
          id: '6',
          senderId: 'user_2',
          text: 'في المساء إن شاء الله ✨',
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
          isRead: true,
        ),
        MessageModel(
          id: '7',
          senderId: 'user_1',
          text: 'لا أستطيع الانتظار 😍',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          isRead: true,
        ),
        MessageModel(
          id: '8',
          senderId: 'user_2',
          text: 'أحبك كثيراً ❤️❤️❤️',
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
          isRead: false,
        ),
      ];
}

// ── Memory Model ───────────────────────────────────

enum MemoryCategory { all, photo, video, occasion }

class MemoryModel {
  final String id;
  final String title;
  final String? description;
  final String? mediaUrl;
  final MemoryCategory category;
  final DateTime date;
  final String? location;
  final int likes;
  final bool isLiked;
  final int colorIndex;

  const MemoryModel({
    required this.id,
    required this.title,
    this.description,
    this.mediaUrl,
    this.category = MemoryCategory.photo,
    required this.date,
    this.location,
    this.likes = 0,
    this.isLiked = false,
    this.colorIndex = 0,
  });

  static List<MemoryModel> get mockMemories => [
        MemoryModel(
          id: '1',
          title: 'أول لقاء 💫',
          description: 'أجمل يوم في حياتي',
          category: MemoryCategory.photo,
          date: DateTime(2023, 6, 15),
          location: 'دبي',
          likes: 12,
          isLiked: true,
          colorIndex: 0,
        ),
        MemoryModel(
          id: '2',
          title: 'رحلة تركيا 🇹🇷',
          category: MemoryCategory.photo,
          date: DateTime(2023, 8, 20),
          location: 'إسطنبول',
          likes: 24,
          isLiked: true,
          colorIndex: 1,
        ),
        MemoryModel(
          id: '3',
          title: 'عيد ميلادك 🎂',
          category: MemoryCategory.occasion,
          date: DateTime(2023, 10, 5),
          likes: 18,
          colorIndex: 2,
        ),
        MemoryModel(
          id: '4',
          title: 'غروب الشمس معاً 🌅',
          category: MemoryCategory.photo,
          date: DateTime(2024, 1, 10),
          location: 'الشاطئ',
          likes: 31,
          colorIndex: 3,
        ),
        MemoryModel(
          id: '5',
          title: 'عشاء رومانسي 🕯️',
          category: MemoryCategory.photo,
          date: DateTime(2024, 2, 14),
          likes: 45,
          isLiked: true,
          colorIndex: 4,
        ),
        MemoryModel(
          id: '6',
          title: 'يوم المطر ☔',
          category: MemoryCategory.video,
          date: DateTime(2024, 3, 22),
          likes: 8,
          colorIndex: 5,
        ),
        MemoryModel(
          id: '7',
          title: 'السوق القديم 🏛️',
          category: MemoryCategory.photo,
          date: DateTime(2024, 4, 15),
          location: 'القاهرة',
          likes: 15,
          colorIndex: 6,
        ),
        MemoryModel(
          id: '8',
          title: 'ليلة النجوم ⭐',
          category: MemoryCategory.photo,
          date: DateTime(2024, 5, 3),
          likes: 22,
          isLiked: true,
          colorIndex: 7,
        ),
        MemoryModel(
          id: '9',
          title: 'الذكرى السنوية 💍',
          category: MemoryCategory.occasion,
          date: DateTime(2024, 6, 15),
          likes: 67,
          isLiked: true,
          colorIndex: 8,
        ),
        MemoryModel(
          id: '10',
          title: 'رحلة البحر 🏖️',
          category: MemoryCategory.video,
          date: DateTime(2024, 7, 20),
          location: 'شرم الشيخ',
          likes: 19,
          colorIndex: 9,
        ),
        MemoryModel(
          id: '11',
          title: 'البيت الجديد 🏠',
          category: MemoryCategory.photo,
          date: DateTime(2024, 9, 1),
          likes: 34,
          isLiked: true,
          colorIndex: 10,
        ),
        MemoryModel(
          id: '12',
          title: 'فيلم معاً 🎬',
          category: MemoryCategory.occasion,
          date: DateTime(2024, 10, 15),
          likes: 11,
          colorIndex: 11,
        ),
      ];
}

// ── Diary Model ───────────────────────────────────

class DiaryModel {
  final String id;
  final String title;
  final String body;
  final String mood;
  final int moodIconCodePoint;
  final DateTime date;
  final String authorName;
  final bool isShared;
  final String? imageUrl;
  final bool isEncrypted;

  const DiaryModel({
    required this.id,
    required this.title,
    required this.body,
    required this.mood,
    required this.moodIconCodePoint,
    required this.date,
    required this.authorName,
    this.isShared = false,
    this.imageUrl,
    this.isEncrypted = false,
  });

  IconData get moodIcon => IconData(moodIconCodePoint, fontFamily: 'MaterialIcons');

  static List<DiaryModel> get mockEntries => [
        DiaryModel(
          id: '1',
          title: 'يوم رائع',
          body:
              'كان يوماً استثنائياً، التقينا في المقهى المفضل وتحدثنا طويلاً عن أحلامنا وخططنا للمستقبل. شعرت بالسعادة الغامرة في كل لحظة.',
          mood: 'سعيد',
          moodIconCodePoint: Icons.sentiment_very_satisfied_rounded.codePoint,
          date: DateTime.now().subtract(const Duration(days: 1)),
          authorName: 'محمد',
          isShared: true,
        ),
        DiaryModel(
          id: '2',
          title: 'اشتياق',
          body:
              'كان يوماً طويلاً بدونك. أتمنى لو كنت معي لنشاهد هذا الغروب الجميل. لونه كان مثل لون شعرك... أحبك.',
          mood: 'متشوق',
          moodIconCodePoint: Icons.favorite_border_rounded.codePoint,
          date: DateTime.now().subtract(const Duration(days: 3)),
          authorName: 'سارة',
          isShared: false,
        ),
        DiaryModel(
          id: '3',
          title: 'ذكريات الرحلة',
          body:
              'لا أزال أتذكر كل تفاصيل رحلتنا. كل مكان زرناه، كل كلمة قيلت، كل ضحكة. إنها لحظات لن أنساها أبداً.',
          mood: 'سعيد',
          moodIconCodePoint: Icons.sentiment_satisfied_alt_rounded.codePoint,
          date: DateTime.now().subtract(const Duration(days: 7)),
          authorName: 'محمد',
          isShared: true,
        ),
        DiaryModel(
          id: '4',
          title: 'أفكار عن المستقبل',
          body:
              'جلست أفكر في مستقبلنا معاً. أتمنى أن يكون مليئاً بالمغامرات والذكريات الجميلة. معك يبدو كل شيء ممكناً.',
          mood: 'متفائل',
          moodIconCodePoint: Icons.star_rounded.codePoint,
          date: DateTime.now().subtract(const Duration(days: 10)),
          authorName: 'سارة',
          isShared: false,
        ),
        DiaryModel(
          id: '5',
          title: 'يوم الذكرى',
          body:
              'اليوم مرت سنة على أجمل يوم في حياتي. اليوم الذي التقيت فيه بنصفي الآخر. أشكر الله كل يوم على هذه النعمة.',
          mood: 'شاكر',
          moodIconCodePoint: Icons.favorite_rounded.codePoint,
          date: DateTime.now().subtract(const Duration(days: 365)),
          authorName: 'محمد',
          isShared: true,
        ),
        DiaryModel(
          id: '6',
          title: 'مساء هادئ',
          body:
              'مساء هادئ مع كوب من الشاي والموسيقى المفضلة. أفتقدك في هذه اللحظات. أتمنى لو كنت هنا.',
          mood: 'هادئ',
          moodIconCodePoint: Icons.nightlight_round.codePoint,
          date: DateTime.now().subtract(const Duration(days: 14)),
          authorName: 'سارة',
          isShared: false,
        ),
      ];
}

// ── Wish Model ─────────────────────────────────────

class WishModel {
  final String id;
  final String title;
  final String category;
  final IconData icon;
  final bool isCompleted;
  final DateTime dateAdded;
  final DateTime? completedDate;
  final bool isBucketList;

  const WishModel({
    required this.id,
    required this.title,
    required this.category,
    required this.icon,
    this.isCompleted = false,
    required this.dateAdded,
    this.completedDate,
    this.isBucketList = false,
  });

  static List<WishModel> get mockWishes => [
        WishModel(
          id: '1',
          title: 'السفر لتركيا',
          category: 'سفر',
          icon: Icons.flight_takeoff_rounded,
          isCompleted: true,
          dateAdded: DateTime(2023, 7, 1),
          completedDate: DateTime(2023, 8, 20),
        ),
        WishModel(
          id: '2',
          title: 'شراء منزلنا',
          category: 'مستقبل',
          icon: Icons.home_rounded,
          dateAdded: DateTime(2023, 9, 1),
        ),
        WishModel(
          id: '3',
          title: 'تعلم لغة جديدة معاً',
          category: 'تعليم',
          icon: Icons.menu_book_rounded,
          dateAdded: DateTime(2023, 10, 15),
        ),
        WishModel(
          id: '4',
          title: 'مشاهدة فيلم في السينما',
          category: 'ترفيه',
          icon: Icons.movie_creation_rounded,
          isCompleted: true,
          dateAdded: DateTime(2024, 1, 5),
          completedDate: DateTime(2024, 2, 14),
        ),
        WishModel(
          id: '5',
          title: 'السفر لباريس',
          category: 'سفر',
          icon: Icons.location_city_rounded,
          dateAdded: DateTime(2024, 3, 1),
        ),
        WishModel(
          id: '6',
          title: 'الغداء في مطعم فاخر',
          category: 'ترفيه',
          icon: Icons.restaurant_rounded,
          dateAdded: DateTime(2024, 4, 10),
        ),
      ];

  static List<WishModel> get mockBucketList => [
        WishModel(
          id: 'b1',
          title: 'مشاهدة شروق الشمس معاً',
          category: 'تجربة',
          icon: Icons.wb_sunny_rounded,
          isBucketList: true,
          dateAdded: DateTime(2023, 6, 1),
        ),
        WishModel(
          id: 'b2',
          title: 'السباحة في البحر',
          category: 'مغامرة',
          icon: Icons.pool_rounded,
          isBucketList: true,
          isCompleted: true,
          dateAdded: DateTime(2023, 7, 1),
          completedDate: DateTime(2024, 7, 20),
        ),
        WishModel(
          id: 'b3',
          title: 'الطبخ معاً',
          category: 'ترفيه',
          icon: Icons.soup_kitchen_rounded,
          isBucketList: true,
          isCompleted: true,
          dateAdded: DateTime(2023, 8, 1),
          completedDate: DateTime(2024, 3, 5),
        ),
        WishModel(
          id: 'b4',
          title: 'الرقص في المطر',
          category: 'رومانسي',
          icon: Icons.music_note_rounded,
          isBucketList: true,
          isCompleted: true,
          dateAdded: DateTime(2023, 9, 1),
          completedDate: DateTime(2024, 3, 22),
        ),
        WishModel(
          id: 'b5',
          title: 'السفر بالقطار',
          category: 'مغامرة',
          icon: Icons.train_rounded,
          isBucketList: true,
          dateAdded: DateTime(2023, 10, 1),
        ),
        WishModel(
          id: 'b6',
          title: 'مشاهدة النجوم في الصحراء',
          category: 'مغامرة',
          icon: Icons.star_rounded,
          isBucketList: true,
          dateAdded: DateTime(2024, 1, 1),
        ),
        WishModel(
          id: 'b7',
          title: 'الاستيقاظ في نفس الوقت',
          category: 'رومانسي',
          icon: Icons.access_time_rounded,
          isBucketList: true,
          dateAdded: DateTime(2024, 2, 1),
        ),
        WishModel(
          id: 'b8',
          title: 'قراءة نفس الكتاب',
          category: 'تعليم',
          icon: Icons.menu_book_rounded,
          isBucketList: true,
          dateAdded: DateTime(2024, 3, 1),
        ),
      ];
}

// ── Event Model ───────────────────────────────────

class EventModel {
  final String id;
  final String title;
  final String type;
  final IconData icon;
  final DateTime date;
  final bool isRecurring;
  final String? note;

  const EventModel({
    required this.id,
    required this.title,
    required this.type,
    required this.icon,
    required this.date,
    this.isRecurring = false,
    this.note,
  });

  static List<EventModel> get mockEvents => [
        EventModel(
          id: '1',
          title: 'الذكرى السنوية',
          type: 'anniversary',
          icon: Icons.diamond_rounded,
          date: DateTime(2024, 6, 15),
          isRecurring: true,
          note: 'سنة كاملة من الحب',
        ),
        EventModel(
          id: '2',
          title: 'عيد ميلادي',
          type: 'birthday',
          icon: Icons.cake_rounded,
          date: DateTime(2024, 10, 5),
          isRecurring: true,
        ),
        EventModel(
          id: '3',
          title: 'عيد ميلاد شريكي',
          type: 'birthday',
          icon: Icons.celebration_rounded,
          date: DateTime(2024, 12, 20),
          isRecurring: true,
        ),
        EventModel(
          id: '4',
          title: 'أول لقاء',
          type: 'special',
          icon: Icons.auto_awesome_rounded,
          date: DateTime(2023, 6, 15),
          isRecurring: true,
          note: 'اليوم الذي غيّر حياتي',
        ),
        EventModel(
          id: '5',
          title: 'رحلة تركيا',
          type: 'travel',
          icon: Icons.flight_takeoff_rounded,
          date: DateTime(2024, 8, 15),
          note: 'موعد السفر المخطط',
        ),
      ];
}
