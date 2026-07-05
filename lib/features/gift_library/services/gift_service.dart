import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GiftModel {
  final String id;
  final String title;
  final String category;
  final String? url;
  final String price;
  final IconData icon;
  final bool isPurchased;
  final DateTime createdAt;
  final String intendedFor; // "me" or "partner"

  GiftModel({
    required this.id,
    required this.title,
    required this.category,
    this.url,
    required this.price,
    required this.icon,
    this.isPurchased = false,
    required this.createdAt,
    required this.intendedFor,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'category': category,
        'url': url,
        'price': price,
        'iconCodePoint': icon.codePoint,
        'iconFontFamily': icon.fontFamily,
        'isPurchased': isPurchased,
        'createdAt': createdAt.toIso8601String(),
        'intendedFor': intendedFor,
      };

  factory GiftModel.fromMap(Map<String, dynamic> map, String id) {
    return GiftModel(
      id: id,
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      url: map['url'],
      price: map['price'] ?? '',
      icon: map['iconCodePoint'] != null
          ? IconData(map['iconCodePoint'], fontFamily: map['iconFontFamily'])
          : Icons.card_giftcard_rounded,
      isPurchased: map['isPurchased'] ?? false,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      intendedFor: map['intendedFor'] ?? 'partner',
    );
  }
}

class GiftService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _getCoupleId(String uid1, String uid2) {
    final List<String> uids = [uid1, uid2];
    uids.sort();
    return uids.join('_');
  }

  CollectionReference<Map<String, dynamic>> _giftsCollection(String coupleId) {
    return _firestore.collection('couples').doc(coupleId).collection('gifts');
  }

  Future<void> addGift({
    required GiftModel gift,
    required String userId,
    required String partnerId,
  }) async {
    final coupleId = _getCoupleId(userId, partnerId);
    await _giftsCollection(coupleId).doc(gift.id).set(gift.toMap());
  }

  Future<void> togglePurchased({
    required String giftId,
    required bool isPurchased,
    required String userId,
    required String partnerId,
  }) async {
    final coupleId = _getCoupleId(userId, partnerId);
    await _giftsCollection(coupleId).doc(giftId).update({'isPurchased': isPurchased});
  }

  Stream<List<GiftModel>> getGiftsStream(String userId, String partnerId) {
    final coupleId = _getCoupleId(userId, partnerId);
    return _giftsCollection(coupleId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => GiftModel.fromMap(doc.data(), doc.id)).toList();
    });
  }
}
