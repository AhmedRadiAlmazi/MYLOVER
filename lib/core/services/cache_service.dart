import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_models.dart';

final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});

class CacheService {
  static const String _messagesBox = 'messages';
  static const String _diariesBox = 'diaries';
  static const String _memoriesBox = 'memories';
  static const String _pendingBox = 'pending_queue';
  static const String _syncTimestampsBox = 'sync_timestamps';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_messagesBox);
    await Hive.openBox<String>(_diariesBox);
    await Hive.openBox<String>(_memoriesBox);
    await Hive.openBox<String>(_pendingBox);
    await Hive.openBox<String>(_syncTimestampsBox);
  }

  // ── Messages ──────────────────────────────────────────────────

  Map<String, dynamic> _messageToJsonMap(MessageModel m) => {
    'id': m.id,
    'senderId': m.senderId,
    'text': m.text,
    'type': m.type.index,
    'mediaUrl': m.mediaUrl,
    'timestamp': m.timestamp.toIso8601String(),
    'isRead': m.isRead,
    'isDeleted': m.isDeleted,
    'replyToId': m.replyToId,
    'isPinned': m.isPinned,
    'isEncrypted': m.isEncrypted,
    'isPending': m.isPending,
    'thumbnailUrl': m.thumbnailUrl,
    'localPath': m.localPath,
  };

  MessageModel _messageFromJsonMap(Map<String, dynamic> map) => MessageModel(
    id: map['id'] ?? '',
    senderId: map['senderId'] ?? '',
    text: map['text'] ?? '',
    type: MessageType.values[(map['type'] is int) ? map['type'] : 0],
    mediaUrl: map['mediaUrl'],
    timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
    isRead: map['isRead'] ?? false,
    isDeleted: map['isDeleted'] ?? false,
    replyToId: map['replyToId'],
    isPinned: map['isPinned'] ?? false,
    isEncrypted: map['isEncrypted'] ?? false,
    isPending: map['isPending'] ?? false,
    thumbnailUrl: map['thumbnailUrl'],
    localPath: map['localPath'],
  );

  Future<void> cacheMessages(String chatId, List<MessageModel> messages) async {
    final box = Hive.box<String>(_messagesBox);
    final list = messages.map(_messageToJsonMap).toList();
    await box.put(chatId, jsonEncode(list));
  }

  /// إضافة رسالة جديدة محلية فواً للعرض الفوري
  Future<void> saveSingleLocalMessage(String chatId, MessageModel message) async {
    final existing = getCachedMessages(chatId);
    // إزالة النسخة المكررة إن وجدت ثم إضافة الرسالة الجديدة في البداية
    existing.removeWhere((m) => m.id == message.id);
    existing.insert(0, message);
    await cacheMessages(chatId, existing);
  }

  /// تحديث حالة الرسالة المعلقة إلى تم الإرسال Synced
  Future<void> markMessageSynced(String chatId, String messageId, {String? mediaUrl, String? thumbnailUrl}) async {
    final existing = getCachedMessages(chatId);
    final index = existing.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final old = existing[index];
      existing[index] = MessageModel(
        id: old.id,
        senderId: old.senderId,
        text: old.text,
        type: old.type,
        mediaUrl: mediaUrl ?? old.mediaUrl,
        timestamp: old.timestamp,
        isRead: old.isRead,
        isDeleted: old.isDeleted,
        replyToId: old.replyToId,
        isPinned: old.isPinned,
        isEncrypted: old.isEncrypted,
        isPending: false, // تحولت إلى تم الإرسال ✔
        thumbnailUrl: thumbnailUrl ?? old.thumbnailUrl,
        localPath: old.localPath,
      );
      await cacheMessages(chatId, existing);
    }
  }

  List<MessageModel> getCachedMessages(String chatId) {
    final box = Hive.box<String>(_messagesBox);
    final rawJson = box.get(chatId);
    if (rawJson == null) return [];
    try {
      final List<dynamic> list = jsonDecode(rawJson);
      return list.map((map) => _messageFromJsonMap(map as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Pending Action Queue (طابور العمليات غير المتصلة) ──────────────

  Future<void> addPendingAction(Map<String, dynamic> actionMap) async {
    final box = Hive.box<String>(_pendingBox);
    final current = getPendingActions();
    current.add(actionMap);
    await box.put('queue', jsonEncode(current));
  }

  List<Map<String, dynamic>> getPendingActions() {
    final box = Hive.box<String>(_pendingBox);
    final rawJson = box.get('queue');
    if (rawJson == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(rawJson);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> removePendingAction(String actionId) async {
    final current = getPendingActions();
    current.removeWhere((item) => item['id'] == actionId);
    final box = Hive.box<String>(_pendingBox);
    await box.put('queue', jsonEncode(current));
  }

  // ── Delta Sync Timestamps (طوابع زمن المزامنة) ───────────────────

  DateTime? getLastSyncTime(String key) {
    final box = Hive.box<String>(_syncTimestampsBox);
    final iso = box.get(key);
    if (iso == null) return null;
    return DateTime.tryParse(iso);
  }

  Future<void> setLastSyncTime(String key, DateTime time) async {
    final box = Hive.box<String>(_syncTimestampsBox);
    await box.put(key, time.toIso8601String());
  }

  // ── Diaries ───────────────────────────────────────────────────

  Future<void> saveDiaries(String coupleId, List<Map<String, dynamic>> diaries) async {
    final box = Hive.box<String>(_diariesBox);
    final jsonStr = jsonEncode(diaries);
    await box.put(coupleId, jsonStr);
  }

  List<Map<String, dynamic>> getDiaries(String coupleId) {
    final box = Hive.box<String>(_diariesBox);
    final jsonStr = box.get(coupleId);
    if (jsonStr == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Memories ──────────────────────────────────────────────────

  Future<void> cacheMemories(List<MemoryModel> memories) async {
    final box = Hive.box<String>(_memoriesBox);
    final list = memories.map((m) => {
      'id': m.id,
      'title': m.title,
      'description': m.description,
      'mediaUrl': m.mediaUrl,
      'category': m.category.index,
      'date': m.date.toIso8601String(),
      'location': m.location,
      'likes': m.likes,
      'isLiked': m.isLiked,
      'colorIndex': m.colorIndex,
    }).toList();
    await box.put('all_memories', jsonEncode(list));
  }

  List<MemoryModel> getCachedMemories() {
    final box = Hive.box<String>(_memoriesBox);
    final rawJson = box.get('all_memories');
    if (rawJson == null) return [];
    try {
      final List<dynamic> list = jsonDecode(rawJson);
      return list.map((map) => MemoryModel(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        description: map['description'],
        mediaUrl: map['mediaUrl'],
        category: MemoryCategory.values[(map['category'] is int) ? map['category'] : 0],
        date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
        location: map['location'],
        likes: map['likes'] ?? 0,
        isLiked: map['isLiked'] ?? false,
        colorIndex: map['colorIndex'] ?? 0,
      )).toList();
    } catch (_) {
      return [];
    }
  }
}
