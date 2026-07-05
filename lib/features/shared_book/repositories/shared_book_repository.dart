import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_page_model.dart';
import '../models/book_page_comment.dart';

class SharedBookRepository {
  final FirebaseFirestore _firestore;

  SharedBookRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _pagesRef =>
      _firestore.collection('book_pages');

  Stream<List<BookPageModel>> getPagesStream() {
    return _pagesRef.orderBy('date', descending: false).snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map((doc) => BookPageModel.fromMap(doc.data(), doc.id))
            .toList();
      },
    );
  }

  Future<void> createPage(BookPageModel page) async {
    await _pagesRef.doc(page.id).set(page.toMap());
  }

  Future<void> updatePage(BookPageModel page) async {
    await _pagesRef.doc(page.id).update(page.toMap());
  }

  Future<void> deletePage(String pageId) async {
    await _pagesRef.doc(pageId).delete();
  }

  Future<void> toggleLike(String pageId, String userId) async {
    final docRef = _pagesRef.doc(pageId);
    final doc = await docRef.get();
    if (doc.exists) {
      final data = doc.data()!;
      final likes = List<String>.from(data['likes'] ?? []);
      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }
      await docRef.update({'likes': likes});
    }
  }

  Stream<List<BookPageComment>> getCommentsStream(String pageId) {
    return _pagesRef
        .doc(pageId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BookPageComment.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addComment(BookPageComment comment) async {
    await _pagesRef
        .doc(comment.pageId)
        .collection('comments')
        .doc(comment.id)
        .set(comment.toMap());
  }
}
