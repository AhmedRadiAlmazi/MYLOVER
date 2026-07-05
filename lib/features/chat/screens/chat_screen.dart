import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/models/app_models.dart' hide currentUserProvider, currentPartnerProvider;
import '../../../core/services/storage_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input_bar.dart';

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isUploading = false;
  MessageModel? _replyingTo;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessageText() {
    if (_textController.text.trim().isEmpty) return;
    
    final text = _textController.text.trim();
    _textController.clear();
    
    _sendToFirebase(text: text, type: MessageType.text);
  }

  Future<void> _sendMedia(File file, MessageType type) async {
    setState(() => _isUploading = true);
    
    try {
      final storageService = ref.read(storageServiceProvider);
      String folder = 'chat_images';
      if (type == MessageType.video) folder = 'chat_videos';
      if (type == MessageType.audio) folder = 'chat_audio';
      
      final downloadUrl = await storageService.uploadFile(file, folder);
      
      await _sendToFirebase(
        text: type == MessageType.image ? 'صورة 📷' : type == MessageType.video ? 'فيديو 🎥' : 'مقطع صوتي 🎵',
        type: type,
        mediaUrl: downloadUrl,
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الرفع: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _sendToFirebase({required String text, required MessageType type, String? mediaUrl}) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null || currentUser.partnerId == null) return;
    
    final chatService = ref.read(chatServiceProvider);
    await chatService.sendMessage(
      senderId: currentUser.id,
      receiverId: currentUser.partnerId!,
      text: text,
      type: type,
      mediaUrl: mediaUrl,
      replyToId: _replyingTo?.id,
    );
    
    setState(() {
      _replyingTo = null;
    });

    // Scroll to bottom
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _markAsRead(List<MessageModel> messages, String currentUserId, String partnerId) {
    final unreadFromPartner = messages.any((m) => !m.isRead && m.senderId == partnerId);
    if (unreadFromPartner) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(chatServiceProvider).markMessagesAsRead(currentUserId, partnerId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesStream = ref.watch(messagesProvider);
    final partnerName = ref.watch(partnerNameProvider);

    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: false, // Ensure layout pushes up above bottom navigation
      resizeToAvoidBottomInset: true, // Allow keyboard to push up chat bar
      appBar: CustomAppBar(
        title: partnerName,
        backgroundColor: AppColors.background.withOpacity(0.9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary, size: 22),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined, color: AppColors.textPrimary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          
          Column(
            children: [
              Expanded(
                child: messagesStream.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  error: (error, stack) => Center(child: Text('خطأ في جلب الرسائل: $error', style: const TextStyle(color: Colors.white))),
                  data: (messages) {
                    if (currentUser != null && currentUser.partnerId != null) {
                      _markAsRead(messages, currentUser.id, currentUser.partnerId!);
                    }

                    if (messages.isEmpty) {
                      return const Center(child: Text('لا توجد رسائل بعد. ابدأ المحادثة!', style: TextStyle(color: AppColors.textHint)));
                    }
                    
                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true, // New messages at bottom
                      padding: const EdgeInsets.all(20),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = currentUser != null && message.senderId == currentUser.id;
                        
                        // Find replied message if any
                        MessageModel? repliedMessage;
                        if (message.replyToId != null) {
                          try {
                            repliedMessage = messages.firstWhere((m) => m.id == message.replyToId);
                          } catch (_) {}
                        }

                        return MessageBubble(
                          message: message,
                          isMe: isMe,
                          repliedMessage: repliedMessage,
                          onSwipeToReply: () {
                            setState(() {
                              _replyingTo = message;
                            });
                          },
                        ).animate().slideY(begin: 0.2).fadeIn();
                      },
                    );
                  },
                ),
              ),
              
              if (_isUploading)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: AppColors.background,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                      SizedBox(width: 8),
                      Text('جاري إرسال المرفق...', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                
              ChatInputBar(
                controller: _textController,
                onSendText: _sendMessageText,
                onSendMedia: _sendMedia,
                replyingTo: _replyingTo,
                onCancelReply: () => setState(() => _replyingTo = null),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
