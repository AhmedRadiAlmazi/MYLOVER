import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/game_models.dart';
import '../services/game_service.dart';

final gameServiceProvider = Provider<GameService>((ref) => GameService());

final coupleIdProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null || user.partnerId == null || user.partnerId!.isEmpty) return null;
  return ref.watch(gameServiceProvider).getCoupleId(user.id, user.partnerId!);
});

final userGameStatsProvider = StreamProvider<GameStatsModel>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return const Stream.empty();
  return ref.watch(gameServiceProvider).streamGameStats(user.id);
});

final partnerGameStatsProvider = StreamProvider<GameStatsModel>((ref) {
  final partner = ref.watch(currentPartnerProvider).value;
  if (partner == null) return const Stream.empty();
  return ref.watch(gameServiceProvider).streamGameStats(partner.id);
});

// ── Game Streams ──

final xoGameStreamProvider = StreamProvider<XOGameState?>((ref) {
  final coupleId = ref.watch(coupleIdProvider);
  if (coupleId == null) return Stream.value(null);
  return ref.watch(gameServiceProvider).streamXOGame(coupleId);
});

final whoKnowsGameStreamProvider = StreamProvider<WhoKnowsGameState?>((ref) {
  final coupleId = ref.watch(coupleIdProvider);
  if (coupleId == null) return Stream.value(null);
  return ref.watch(gameServiceProvider).streamWhoKnowsGame(coupleId);
});

final truthDareGameStreamProvider = StreamProvider<TruthDareGameState?>((ref) {
  final coupleId = ref.watch(coupleIdProvider);
  if (coupleId == null) return Stream.value(null);
  return ref.watch(gameServiceProvider).streamTruthDareGame(coupleId);
});

final completeSentenceGameStreamProvider = StreamProvider<CompleteSentenceGameState?>((ref) {
  final coupleId = ref.watch(coupleIdProvider);
  if (coupleId == null) return Stream.value(null);
  return ref.watch(gameServiceProvider).streamCompleteSentenceGame(coupleId);
});

final drawGuessGameStreamProvider = StreamProvider<DrawGuessGameState?>((ref) {
  final coupleId = ref.watch(coupleIdProvider);
  if (coupleId == null) return Stream.value(null);
  return ref.watch(gameServiceProvider).streamDrawGuessGame(coupleId);
});

final voiceChallengeGameStreamProvider = StreamProvider<VoiceChallengeGameState?>((ref) {
  final coupleId = ref.watch(coupleIdProvider);
  if (coupleId == null) return Stream.value(null);
  return ref.watch(gameServiceProvider).streamVoiceChallengeGame(coupleId);
});

final wheelGameStreamProvider = StreamProvider<WheelGameState?>((ref) {
  final coupleId = ref.watch(coupleIdProvider);
  if (coupleId == null) return Stream.value(null);
  return ref.watch(gameServiceProvider).streamWheelGame(coupleId);
});

final memoryQuizGameStreamProvider = StreamProvider<MemoryQuizGameState?>((ref) {
  final coupleId = ref.watch(coupleIdProvider);
  if (coupleId == null) return Stream.value(null);
  return ref.watch(gameServiceProvider).streamMemoryQuizGame(coupleId);
});

// ── Daily Challenge Stream ──

final dailyChallengeDateKeyProvider = Provider<String>((ref) {
  return DateFormat('yyyy_MM_dd').format(DateTime.now());
});

final dailyChallengeStreamProvider = StreamProvider<DailyChallengeState?>((ref) {
  final coupleId = ref.watch(coupleIdProvider);
  final dateKey = ref.watch(dailyChallengeDateKeyProvider);
  if (coupleId == null) return Stream.value(null);
  return ref.watch(gameServiceProvider).streamDailyChallenge(coupleId, dateKey);
});
