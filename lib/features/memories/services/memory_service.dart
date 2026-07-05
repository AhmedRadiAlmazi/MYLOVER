import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/app_models.dart';

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
    
    // تحويل MemoryModel إلى Map (يجب أن نضيف toMap إلى MemoryModel)
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

  // جلب الذكريات كبث حي
  Stream<List<MemoryModel>> getMemoriesStream(String userId, String partnerId) {
    final coupleId = _getCoupleId(userId, partnerId);
    return _memoriesCollection(coupleId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
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
}
