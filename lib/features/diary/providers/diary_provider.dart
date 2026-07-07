import 'package:flutter/material.dart' show IconData, Icons;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/app_models.dart';
import '../../../core/services/cache_service.dart';
import '../../../features/diary/services/diary_service.dart';
import '../../auth/providers/auth_provider.dart';

final diaryServiceProvider = Provider<DiaryService>((ref) {
  final cacheService = ref.watch(cacheServiceProvider);
  return DiaryService(cacheService);
});

final diaryEntriesProvider = StreamProvider<List<DiaryModel>>((ref) {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null || currentUser.partnerId == null) {
    return Stream.value([]);
  }
  
  final diaryService = ref.watch(diaryServiceProvider);
  return diaryService.getDiariesStream(currentUser.id, currentUser.partnerId!);
});

final selectedDiaryCategoryProvider = StateProvider<String>((ref) => 'يومياتي');

final filteredDiaryProvider = Provider<List<DiaryModel>>((ref) {
  final entriesStream = ref.watch(diaryEntriesProvider);
  final entries = entriesStream.value ?? [];
  final category = ref.watch(selectedDiaryCategoryProvider);
  final currentUser = ref.watch(currentUserProvider).value;
  final myName = currentUser?.name ?? '';
  
  switch (category) {
    case 'مشتركة':
      return entries.where((e) => e.isShared).toList();
    case 'يومياته/يومياتها':
      return entries.where((e) => e.authorName != myName).toList();
    default:
      return entries.where((e) => e.authorName == myName).toList();
  }
});

final newEntryMoodProvider = StateProvider<IconData>((ref) => Icons.sentiment_satisfied_rounded);

