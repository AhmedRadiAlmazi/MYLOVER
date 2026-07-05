import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wish_model.dart';
import '../../shared_book/models/book_page_model.dart';
import '../../shared_book/repositories/shared_book_repository.dart';
import 'package:uuid/uuid.dart';

class WishesRepository {
  final FirebaseFirestore _firestore;
  final SharedBookRepository _sharedBookRepository;

  WishesRepository(this._sharedBookRepository, {FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _wishesRef =>
      _firestore.collection('wishlists');

  Stream<List<WishModel>> getWishesStream() {
    return _wishesRef.orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map((doc) => WishModel.fromMap(doc.data(), doc.id))
            .toList();
      },
    );
  }

  Future<void> createWish(WishModel wish) async {
    await _wishesRef.doc(wish.id).set(wish.toMap());
  }

  Future<void> updateWish(WishModel wish) async {
    await _wishesRef.doc(wish.id).update(wish.toMap());
  }

  Future<void> deleteWish(String wishId) async {
    await _wishesRef.doc(wishId).delete();
  }

  Future<void> completeWishAndConvertToMemory(
    WishModel wish,
    String memoryStory,
    List<String> imageBase64List,
  ) async {
    // 1. Update the wish status to completed
    final updatedWish = wish.copyWith(status: WishStatus.completed, progress: 1.0);
    await updateWish(updatedWish);

    // 2. Create a new Shared Book Page
    final newPage = BookPageModel(
      id: const Uuid().v4(),
      title: 'تحقيق أمنية: ${wish.title}',
      content: memoryStory,
      date: DateTime.now(),
      imageUrls: imageBase64List,
      createdBy: 'currentUser', // Replace with actual user ID
      createdAt: DateTime.now(),
    );

    await _sharedBookRepository.createPage(newPage);
  }
}
