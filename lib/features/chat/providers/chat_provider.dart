import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/app_models.dart';
import '../../../features/chat/services/chat_service.dart';
import '../../auth/providers/auth_provider.dart';

final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

final messagesProvider = StreamProvider<List<MessageModel>>((ref) {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null || currentUser.partnerId == null) {
    return Stream.value([]);
  }
  
  final chatService = ref.watch(chatServiceProvider);
  return chatService.getMessages(currentUser.id, currentUser.partnerId!);
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

