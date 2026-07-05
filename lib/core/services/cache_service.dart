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

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_messagesBox);
    await Hive.openBox<String>(_diariesBox);
    await Hive.openBox<String>(_memoriesBox);
  }

  // ── Messages ──────────────────────────────────────────────────

  Future<void> cacheMessages(String chatId, List<MessageModel> messages) async {
    final box = Hive.box<String>(_messagesBox);
    // Since we don't have a toMap for MessageModel, we'd need to serialize it.
    // For this example, we assume we have a toMap or we just store dummy strings if not.
    // We will serialize them as JSON.
    // In a full implementation, MessageModel needs `toMap` and `fromMap`.
  }

  List<MessageModel> getCachedMessages(String chatId) {
    final box = Hive.box<String>(_messagesBox);
    // return parsed messages
    return [];
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
    
    final List<dynamic> decoded = jsonDecode(jsonStr);
    return decoded.map((e) => e as Map<String, dynamic>).toList();
  }

  // ── Memories ──────────────────────────────────────────────────

  Future<void> cacheMemories(List<MemoryModel> memories) async {
    final box = Hive.box<String>(_memoriesBox);
    // Serialize and save
  }

  List<MemoryModel> getCachedMemories() {
    final box = Hive.box<String>(_memoriesBox);
    return [];
  }
}
