import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/ai/services/ai_service.dart';

class AiMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  AiMessage({required this.text, required this.isUser, required this.timestamp});
}

final aiServiceProvider = Provider<AiService>((ref) => AiService());

class AiChatNotifier extends StateNotifier<List<AiMessage>> {
  final AiService _aiService;

  AiChatNotifier(this._aiService) : super([]) {
    _aiService.startChat();
    // Add initial welcome message
    state = [
      AiMessage(
        text: 'مرحباً بكما في "كوني أنت" 💖\nأنا مستشاركما الذكي، كيف يمكنني مساعدتكما اليوم؟ (نصيحة، فكرة لهدية، اقتراح موعد؟)',
        isUser: false,
        timestamp: DateTime.now(),
      )
    ];
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = AiMessage(text: text, isUser: true, timestamp: DateTime.now());
    state = [userMsg, ...state];

    // Add empty bot message for loading state (can be used to show typing)
    final typingMsg = AiMessage(text: '...', isUser: false, timestamp: DateTime.now());
    state = [typingMsg, ...state];

    final response = await _aiService.sendMessage(text);

    // Replace typing message with actual response
    state = [
      AiMessage(text: response, isUser: false, timestamp: DateTime.now()),
      ...state.skip(1),
    ];
  }
}

final aiChatProvider = StateNotifierProvider<AiChatNotifier, List<AiMessage>>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return AiChatNotifier(aiService);
});

