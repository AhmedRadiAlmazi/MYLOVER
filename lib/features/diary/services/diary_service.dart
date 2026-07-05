import 'package:flutter/material.dart' show IconData;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/app_models.dart';
import '../../../core/services/cache_service.dart';

class DiaryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CacheService _cacheService;

  DiaryService(this._cacheService);

  // الحصول على معرف الغرفة الفريد بين المستخدمين لليوميات المشتركة
  String _getCoupleId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  // إضافة يومية جديدة
  Future<void> addDiaryEntry({
    required DiaryModel entry,
    required String userId,
    required String partnerId,
  }) async {
    final String coupleId = _getCoupleId(userId, partnerId);
    final map = _diaryToMap(entry);
    map['id'] = entry.id;
    
    // حفظ محلي أولاً (Optimistic UI)
    final currentCached = _cacheService.getDiaries(coupleId);
    currentCached.insert(0, map);
    await _cacheService.saveDiaries(coupleId, currentCached);
    
    try {
      await _firestore
          .collection('diaries')
          .doc(coupleId)
          .collection('entries')
          .doc(entry.id)
          .set(map);
    } catch (e) {
      // فشل الرفع لعدم وجود إنترنت مثلاً، سيبقى محلياً لحين المزامنة.
    }
  }

  // جلب اليوميات (أوفلاين أولاً ثم تحديث متزامن)
  Stream<List<DiaryModel>> getDiariesStream(String userId, String partnerId) async* {
    final String coupleId = _getCoupleId(userId, partnerId);
    
    // 1. إرسال البيانات المحلية فوراً إن وجدت
    final cachedMaps = _cacheService.getDiaries(coupleId);
    if (cachedMaps.isNotEmpty) {
      yield cachedMaps.map((map) => _diaryFromMap(map, map['id'])).toList();
    }

    // 2. الاستماع لقاعدة البيانات وتحديث المحلي بشكل مستمر
    yield* _firestore
        .collection('diaries')
        .doc(coupleId)
        .collection('entries')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      final maps = snapshot.docs.map((doc) {
        final m = doc.data();
        m['id'] = doc.id;
        return m;
      }).toList();
      
      // المزامنة والحفظ محلياً
      _cacheService.saveDiaries(coupleId, maps);
      
      return maps.map((map) => _diaryFromMap(map, map['id'])).toList();
    });
  }

  // حذف يومية
  Future<void> deleteDiary(String diaryId, String userId, String partnerId) async {
    final String coupleId = _getCoupleId(userId, partnerId);
    
    await _firestore
        .collection('diaries')
        .doc(coupleId)
        .collection('entries')
        .doc(diaryId)
        .delete();
  }

  // دوال التحويل من وإلى Map
  Map<String, dynamic> _diaryToMap(DiaryModel entry) {
    return {
      'id': entry.id,
      'title': entry.title,
      'body': entry.body,
      'mood': entry.mood,
      'moodIconCodePoint': entry.moodIcon.codePoint, // تخزين الرمز فقط
      'date': entry.date.toIso8601String(),
      'authorName': entry.authorName,
      'isShared': entry.isShared,
      'imageUrl': entry.imageUrl,
    };
  }

  DiaryModel _diaryFromMap(Map<String, dynamic> map, String id) {
    return DiaryModel(
      id: id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      mood: map['mood'] ?? '',
      moodIcon: IconData(map['moodIconCodePoint'] ?? 0xe533, fontFamily: 'MaterialIcons'),
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      authorName: map['authorName'] ?? '',
      isShared: map['isShared'] ?? false,
      imageUrl: map['imageUrl'],
    );
  }
}
