import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book_page_model.dart';
import '../repositories/shared_book_repository.dart';
import '../services/storage_service.dart';

final sharedBookStorageProvider = Provider<SharedBookStorageService>((ref) {
  return SharedBookStorageService();
});

final sharedBookRepositoryProvider = Provider<SharedBookRepository>((ref) {
  return SharedBookRepository();
});

final bookPagesStreamProvider = StreamProvider<List<BookPageModel>>((ref) {
  final repository = ref.watch(sharedBookRepositoryProvider);
  return repository.getPagesStream();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredBookPagesProvider = Provider<List<BookPageModel>>((ref) {
  final pagesAsyncValue = ref.watch(bookPagesStreamProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

  return pagesAsyncValue.when(
    data: (pages) {
      if (searchQuery.isEmpty) {
        return pages;
      }
      return pages.where((page) {
        return page.title.toLowerCase().contains(searchQuery) ||
               page.content.toLowerCase().contains(searchQuery);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
