import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/app_models.dart';
import '../../../features/memories/services/memory_service.dart';
import '../../auth/providers/auth_provider.dart';

import '../../../core/services/cache_service.dart';

final memoryServiceProvider = Provider<MemoryService>((ref) {
  final cache = ref.watch(cacheServiceProvider);
  return MemoryService(cache);
});

// جلب الذكريات كبث حي من Firebase
final memoriesStreamProvider = StreamProvider<List<MemoryModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  final userId = (user?.id.isNotEmpty == true) ? user!.id : 'user_1';
  final partnerId = (user?.partnerId?.isNotEmpty == true) ? user!.partnerId! : 'user_2';

  final service = ref.watch(memoryServiceProvider);
  return service.getMemoriesStream(userId, partnerId);
});

// الفئة المحددة حالياً (null تعني الكل)
final selectedCategoryProvider = StateProvider<MemoryCategory?>((ref) => null);

// الذكريات المفلترة حسب الفئة
final filteredMemoriesProvider = Provider<List<MemoryModel>>((ref) {
  final memoriesAsync = ref.watch(memoriesStreamProvider);
  final memories = memoriesAsync.value ?? [];
  
  final category = ref.watch(selectedCategoryProvider);
  if (category == null || category == MemoryCategory.all) return memories;
  
  return memories.where((m) => m.category == category).toList();
});

// الذكرى المحددة حالياً (عند فتح تفاصيلها)
final selectedMemoryProvider = StateProvider<MemoryModel?>((ref) => null);

