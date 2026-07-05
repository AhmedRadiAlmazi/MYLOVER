import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wish_model.dart';
import '../repositories/wishes_repository.dart';
import '../../shared_book/providers/shared_book_providers.dart';

final wishesRepositoryProvider = Provider<WishesRepository>((ref) {
  final sharedBookRepo = ref.watch(sharedBookRepositoryProvider);
  return WishesRepository(sharedBookRepo);
});

final wishesStreamProvider = StreamProvider<List<WishModel>>((ref) {
  final repository = ref.watch(wishesRepositoryProvider);
  return repository.getWishesStream();
});

final wishesStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final wishesAsyncValue = ref.watch(wishesStreamProvider);
  
  return wishesAsyncValue.when(
    data: (wishes) {
      if (wishes.isEmpty) {
        return {'total': 0, 'completed': 0, 'pending': 0, 'percentage': 0.0};
      }
      
      int completed = wishes.where((w) => w.status == WishStatus.completed).length;
      int pending = wishes.length - completed;
      double percentage = (completed / wishes.length) * 100;
      
      return {
        'total': wishes.length,
        'completed': completed,
        'pending': pending,
        'percentage': percentage,
      };
    },
    loading: () => {'total': 0, 'completed': 0, 'pending': 0, 'percentage': 0.0},
    error: (_, __) => {'total': 0, 'completed': 0, 'pending': 0, 'percentage': 0.0},
  );
});
