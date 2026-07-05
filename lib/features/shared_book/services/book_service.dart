import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChapterModel {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final int pages;
  final DateTime date;
  final DateTime createdAt;

  ChapterModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.pages = 0,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'iconCodePoint': icon.codePoint,
        'iconFontFamily': icon.fontFamily,
        'pages': pages,
        'date': date.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory ChapterModel.fromMap(Map<String, dynamic> map, String id) {
    return ChapterModel(
      id: id,
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      icon: map['iconCodePoint'] != null
          ? IconData(map['iconCodePoint'], fontFamily: map['iconFontFamily'])
          : Icons.menu_book_rounded,
      pages: map['pages'] ?? 0,
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    );
  }
}

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _getCoupleId(String uid1, String uid2) {
    final List<String> uids = [uid1, uid2];
    uids.sort();
    return uids.join('_');
  }

  CollectionReference<Map<String, dynamic>> _bookCollection(String coupleId) {
    return _firestore.collection('couples').doc(coupleId).collection('chapters');
  }

  Future<void> addChapter({
    required ChapterModel chapter,
    required String userId,
    required String partnerId,
  }) async {
    final coupleId = _getCoupleId(userId, partnerId);
    await _bookCollection(coupleId).doc(chapter.id).set(chapter.toMap());
  }

  Stream<List<ChapterModel>> getChaptersStream(String userId, String partnerId) {
    final coupleId = _getCoupleId(userId, partnerId);
    return _bookCollection(coupleId)
        .orderBy('createdAt', descending: false) // ترتيب الفصول حسب وقت إنشائها
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChapterModel.fromMap(doc.data(), doc.id)).toList();
    });
  }
}
