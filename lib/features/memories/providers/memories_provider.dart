import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/app_models.dart';
import '../../../features/memories/services/memory_service.dart';
import '../../auth/providers/auth_provider.dart';

final memoryServiceProvider = Provider<MemoryService>((ref) => MemoryService());

// جلب الذكريات كبث حي من Firebase
final memoriesStreamProvider = StreamProvider<List<MemoryModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null || user.partnerId == null || user.partnerId!.isEmpty) {
    return Stream.value([]);
  }
  
  final service = ref.watch(memoryServiceProvider);
  return service.getMemoriesStream(user.id, user.partnerId!);
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

