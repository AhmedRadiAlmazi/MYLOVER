import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SurpriseModel {
  final String id;
  final String title;
  final String message;
  final IconData icon;
  final bool isOpened;
  final String createdBy;
  final DateTime createdAt;
  final String? imageUrl;

  SurpriseModel({
    required this.id,
    required this.title,
    required this.message,
    required this.icon,
    this.isOpened = false,
    required this.createdBy,
    required this.createdAt,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'message': message,
        'iconCodePoint': icon.codePoint,
        'iconFontFamily': icon.fontFamily,
        'isOpened': isOpened,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
        if (imageUrl != null) 'imageUrl': imageUrl,
      };

  factory SurpriseModel.fromMap(Map<String, dynamic> map, String id) {
    return SurpriseModel(
      id: id,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      icon: map['iconCodePoint'] != null
          ? IconData(map['iconCodePoint'], fontFamily: map['iconFontFamily'])
          : Icons.redeem_rounded,
      isOpened: map['isOpened'] ?? false,
      createdBy: map['createdBy'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      imageUrl: map['imageUrl'],
    );
  }
}

class SurpriseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _getCoupleId(String uid1, String uid2) {
    final List<String> uids = [uid1, uid2];
    uids.sort();
    return uids.join('_');
  }

  CollectionReference<Map<String, dynamic>> _surprisesCollection(String coupleId) {
    return _firestore.collection('couples').doc(coupleId).collection('surprises');
  }

  Future<void> addSurprise({
    required SurpriseModel surprise,
    required String userId,
    required String partnerId,
  }) async {
    final coupleId = _getCoupleId(userId, partnerId);
    await _surprisesCollection(coupleId).doc(surprise.id).set(surprise.toMap());
  }

  Future<void> markAsOpened(String surpriseId, String userId, String partnerId) async {
    final coupleId = _getCoupleId(userId, partnerId);
    await _surprisesCollection(coupleId).doc(surpriseId).update({'isOpened': true});
  }

  Stream<List<SurpriseModel>> getSurprisesStream(String userId, String partnerId) {
    final coupleId = _getCoupleId(userId, partnerId);
    return _surprisesCollection(coupleId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => SurpriseModel.fromMap(doc.data(), doc.id)).toList();
    });
  }
}
