import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/app_models.dart';
import 'package:flutter/material.dart';

class WishesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _getCoupleId(String uid1, String uid2) {
    final List<String> uids = [uid1, uid2];
    uids.sort();
    return uids.join('_');
  }

  CollectionReference<Map<String, dynamic>> _wishesCollection(String coupleId) {
    return _firestore.collection('couples').doc(coupleId).collection('wishes');
  }

  // إضافة أمنية أو مهمة
  Future<void> addWish({
    required WishModel wish,
    required String userId,
    required String partnerId,
  }) async {
    final coupleId = _getCoupleId(userId, partnerId);
    
    final wishData = {
      'id': wish.id,
      'title': wish.title,
      'category': wish.category,
      'iconCodePoint': wish.icon.codePoint,
      'iconFontFamily': wish.icon.fontFamily,
      'isCompleted': wish.isCompleted,
      'dateAdded': wish.dateAdded.toIso8601String(),
      'isBucketList': wish.isBucketList,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _wishesCollection(coupleId).doc(wish.id).set(wishData);
  }

  // تحديث حالة الأمنية (إنجاز / غير منجز)
  Future<void> toggleWish(String wishId, bool isCompleted, String userId, String partnerId) async {
    final coupleId = _getCoupleId(userId, partnerId);
    await _wishesCollection(coupleId).doc(wishId).update({
      'isCompleted': isCompleted,
    });
  }

  // جلب الأمنيات كبث حي
  Stream<List<WishModel>> getWishesStream(String userId, String partnerId) {
    final coupleId = _getCoupleId(userId, partnerId);
    return _wishesCollection(coupleId)
        .orderBy('dateAdded', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return WishModel(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          category: data['category'] ?? 'عام',
          icon: data['iconCodePoint'] != null 
              ? IconData(data['iconCodePoint'], fontFamily: data['iconFontFamily']) 
              : Icons.star_rounded,
          isCompleted: data['isCompleted'] ?? false,
          dateAdded: data['dateAdded'] != null ? DateTime.parse(data['dateAdded']) : DateTime.now(),
          isBucketList: data['isBucketList'] ?? false,
        );
      }).toList();
    });
  }
}
