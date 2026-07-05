import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/app_models.dart';
import '../../../core/widgets/common_widgets.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onSwipeToReply,
    this.repliedMessage,
  });

  final MessageModel message;
  final bool isMe;
  final VoidCallback? onSwipeToReply;
  final MessageModel? repliedMessage;

  Widget _buildRepliedMessagePreview() {
    if (repliedMessage == null) return const SizedBox.shrink();

    String previewText = repliedMessage!.text;
    if (repliedMessage!.type == MessageType.image) previewText = 'صورة 📷';
    if (repliedMessage!.type == MessageType.video) previewText = 'فيديو 🎥';
    if (repliedMessage!.type == MessageType.audio) previewText = 'مقطع صوتي 🎵';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          right: BorderSide(color: isMe ? Colors.white : AppColors.primary, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isMe && repliedMessage!.senderId == message.senderId 
                ? 'أنت' 
                : (!isMe && repliedMessage!.senderId == message.senderId)
                    ? 'الطرف الآخر'
                    : (isMe ? 'الطرف الآخر' : 'أنت'),
            style: GoogleFonts.tajawal(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isMe ? Colors.white : AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            previewText,
            style: GoogleFonts.tajawal(
              fontSize: 13,
              color: isMe ? Colors.white70 : AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    if (message.type == MessageType.image && message.mediaUrl != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRepliedMessagePreview(),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SmartImage(
              imageUrl: message.mediaUrl!,
              fit: BoxFit.cover,
            ),
          ),
        ],
      );
    } else if (message.type == MessageType.video && message.mediaUrl != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRepliedMessagePreview(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.videocam_rounded, color: isMe ? Colors.white : AppColors.primary),
              const SizedBox(width: 8),
              Text('فيديو', style: GoogleFonts.tajawal(color: isMe ? Colors.white : AppColors.textPrimary)),
            ],
          ),
        ],
      );
    } else if (message.type == MessageType.audio && message.mediaUrl != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRepliedMessagePreview(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_circle_fill_rounded, color: isMe ? Colors.white : AppColors.primary, size: 36),
              const SizedBox(width: 8),
              Container(width: 100, height: 4, decoration: BoxDecoration(color: isMe ? Colors.white54 : AppColors.primary.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRepliedMessagePreview(),
        Text(
          message.text,
          style: GoogleFonts.tajawal(
            fontSize: 15,
            color: isMe ? Colors.white : AppColors.textPrimary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(message.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (onSwipeToReply != null) {
          onSwipeToReply!();
        }
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.reply_rounded, color: AppColors.primary),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.reply_rounded, color: AppColors.primary),
      ),
      child: Align(
        alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isMe ? AppColors.purpleGradient : null,
                  color: isMe ? null : AppColors.card,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomRight: Radius.circular(isMe ? 18 : 4),
                    bottomLeft: Radius.circular(isMe ? 4 : 18),
                  ),
                  border: isMe ? null : Border.all(color: AppColors.divider),
                ),
                child: _buildMessageContent(context),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('hh:mm a').format(message.timestamp),
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.done_all,
                      size: 14,
                      color: message.isRead ? AppColors.info : AppColors.textHint,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
