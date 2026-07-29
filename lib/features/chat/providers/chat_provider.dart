import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/app_models.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/services/encryption_service.dart';
import '../../../features/chat/services/chat_service.dart';
import '../../auth/providers/auth_provider.dart';

final chatServiceProvider = Provider<ChatService>((ref) {
  final encryption = ref.watch(encryptionServiceProvider);
  final cache = ref.watch(cacheServiceProvider);
  return ChatService(encryption, cache);
});

final messagesProvider = StreamProvider<List<MessageModel>>((ref) {
  final currentUser = ref.watch(currentUserProvider).value;
  final userId = currentUser?.id.isNotEmpty == true ? currentUser!.id : 'user_1';
  final partnerId = currentUser?.partnerId?.isNotEmpty == true ? currentUser!.partnerId! : 'user_2';

  final chatService = ref.watch(chatServiceProvider);
  return chatService.getMessages(userId, partnerId, limit: 50);
});

final isTypingProvider = StateProvider<bool>((ref) => false);

final partnerNameProvider = Provider<String>((ref) {
  final partner = ref.watch(currentPartnerProvider).value;
  return partner?.name ?? 'الشريك';
});

final partnerOnlineProvider = Provider<bool>((ref) {
  final partner = ref.watch(currentPartnerProvider).value;
  return partner?.isOnline ?? false;
});

