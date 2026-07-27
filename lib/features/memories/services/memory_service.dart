import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/app_models.dart';

class MemoryCommentModel {
  final String id;
  final String userName;
  final String text;
  final DateTime createdAt;

  const MemoryCommentModel({
    required this.id,
    required this.userName,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'createdAt': Timestamp.fromDate(createdAt),
      'text': text,
    };
  }

  factory MemoryCommentModel.fromMap(Map<String, dynamic> map, String id) {
    return MemoryCommentModel(
      id: id,
      userName: map['userName'] ?? '',
      text: map['text'] ?? '',
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }
}

class MemoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _getCoupleId(String uid1, String uid2) {
    final List<String> uids = [uid1, uid2];
    uids.sort();
    return uids.join('_');
  }

  CollectionReference<Map<String, dynamic>> _memoriesCollection(String coupleId) {
    return _firestore.collection('couples').doc(coupleId).collection('memories');
  }

  // إضافة ذكرى جديدة
  Future<void> addMemory({
    required MemoryModel memory,
    required String userId,
    required String partnerId,
  }) async {
    final coupleId = _getCoupleId(userId, partnerId);
    
    final memoryData = {
      'id': memory.id,
      'title': memory.title,
      'description': memory.description,
      'mediaUrl': memory.mediaUrl,
      'category': memory.category.name,
      'date': memory.date.toIso8601String(),
      'location': memory.location,
      'likes': memory.likes,
      'isLiked': memory.isLiked,
      'colorIndex': memory.colorIndex,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _memoriesCollection(coupleId).doc(memory.id).set(memoryData);
  }

  // جلب الذكريات كبث حي مع الترقيم Pagination لشبكات 2G (20 ذكرى لكل دفعة)
  Stream<List<MemoryModel>> getMemoriesStream(
    String userId,
    String partnerId, {
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) {
    final coupleId = _getCoupleId(userId, partnerId);
    
    Query<Map<String, dynamic>> query = _memoriesCollection(coupleId)
        .orderBy('date', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return MemoryModel(
          id: data['id'] ?? '',
          title: data['title'] ?? '',
          description: data['description'],
          mediaUrl: data['mediaUrl'],
          category: MemoryCategory.values.firstWhere(
            (e) => e.name == data['category'],
            orElse: () => MemoryCategory.photo,
          ),
          date: data['date'] != null ? DateTime.parse(data['date']) : DateTime.now(),
          location: data['location'],
          likes: data['likes'] ?? 0,
          isLiked: data['isLiked'] ?? false,
          colorIndex: data['colorIndex'] ?? 0,
        );
      }).toList();
    });
  }

  // تحديث عدد الإعجابات
  Future<void> toggleLike(String userId, String partnerId, String memoryId, bool currentIsLiked, int currentLikes) async {
    final coupleId = _getCoupleId(userId, partnerId);
    await _memoriesCollection(coupleId).doc(memoryId).update({
      'isLiked': !currentIsLiked,
      'likes': currentIsLiked ? currentLikes - 1 : currentLikes + 1,
    });
  }

  // تحديث الذكرى
  Future<void> updateMemory({
    required String userId,
    required String partnerId,
    required MemoryModel memory,
  }) async {
    final coupleId = _getCoupleId(userId, partnerId);
    await _memoriesCollection(coupleId).doc(memory.id).update({
      'title': memory.title,
      'description': memory.description,
      'location': memory.location,
    });
  }

  // حذف ذكرى
  Future<void> deleteMemory(String userId, String partnerId, String memoryId) async {
    final coupleId = _getCoupleId(userId, partnerId);
    await _memoriesCollection(coupleId).doc(memoryId).delete();
  }

  // إضافة تعليق
  Future<void> addComment({
    required String userId,
    required String partnerId,
    required String memoryId,
    required MemoryCommentModel comment,
  }) async {
    final coupleId = _getCoupleId(userId, partnerId);
    await _memoriesCollection(coupleId)
        .doc(memoryId)
        .collection('comments')
        .doc(comment.id)
        .set(comment.toMap());
  }

  // جلب التعليقات كبث حي
  Stream<List<MemoryCommentModel>> getCommentsStream({
    required String userId,
    required String partnerId,
    required String memoryId,
  }) {
    final coupleId = _getCoupleId(userId, partnerId);
    return _memoriesCollection(coupleId)
        .doc(memoryId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MemoryCommentModel.fromMap(doc.data(), doc.id)).toList();
    });
  }
}
