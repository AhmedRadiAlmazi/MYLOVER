import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/app_models.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSendText,
    required this.onSendMedia,
    this.replyingTo,
    this.onCancelReply,
  });

  final TextEditingController controller;
  final VoidCallback onSendText;
  final Function(File, MessageType) onSendMedia;
  final MessageModel? replyingTo;
  final VoidCallback? onCancelReply;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {
        _isTyping = widget.controller.text.trim().isNotEmpty;
      });
    });
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('إرفاق ملف', style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _AttachmentOption(
                    icon: Icons.image_rounded,
                    label: 'صورة',
                    color: Colors.purple,
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                  _AttachmentOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'كاميرا',
                    color: Colors.pink,
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                  _AttachmentOption(
                    icon: Icons.videocam_rounded,
                    label: 'فيديو',
                    color: Colors.orange,
                    onTap: _pickVideo,
                  ),
                  _AttachmentOption(
                    icon: Icons.audiotrack_rounded,
                    label: 'صوت',
                    color: Colors.blue,
                    onTap: _pickAudio,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (pickedFile != null) {
      widget.onSendMedia(File(pickedFile.path), MessageType.image);
    }
  }

  Future<void> _pickVideo() async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      widget.onSendMedia(File(pickedFile.path), MessageType.video);
    }
  }

  Future<void> _pickAudio() async {
    Navigator.pop(context);
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      widget.onSendMedia(File(result.files.single.path!), MessageType.audio);
    }
  }

  Widget _buildReplyPreview() {
    if (widget.replyingTo == null) return const SizedBox.shrink();
    
    String previewText = widget.replyingTo!.text;
    if (widget.replyingTo!.type == MessageType.image) previewText = 'صورة 📷';
    if (widget.replyingTo!.type == MessageType.video) previewText = 'فيديو 🎥';
    if (widget.replyingTo!.type == MessageType.audio) previewText = 'مقطع صوتي 🎵';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(left: BorderSide(color: AppColors.primary, width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'الرد على رسالة',
                  style: GoogleFonts.tajawal(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  previewText,
                  style: GoogleFonts.tajawal(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textHint),
            onPressed: widget.onCancelReply,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.95),
        border: const Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildReplyPreview(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Attachment button on the far right/left
                  IconButton(
                    onPressed: _showAttachmentOptions,
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 26),
                  ),
                  const SizedBox(width: 4),
                  // Text input field
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.emoji_emotions_outlined, color: AppColors.textHint, size: 22),
                          ),
                          Expanded(
                            child: TextField(
                              controller: widget.controller,
                              maxLines: null,
                              textInputAction: TextInputAction.newline,
                              style: GoogleFonts.tajawal(color: AppColors.textPrimary, fontSize: 15),
                              decoration: InputDecoration(
                                hintText: 'اكتب رسالة...',
                                hintStyle: GoogleFonts.tajawal(color: AppColors.textHint, fontSize: 14),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send/Mic button
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      gradient: _isTyping ? AppColors.primaryGradient : null,
                      color: _isTyping ? null : AppColors.card,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _isTyping ? widget.onSendText : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ميزة التسجيل الصوتي المباشر قيد التطوير. يمكنك إرفاق ملف صوتي من الزر المجاور +'))
                        );
                      },
                      icon: Icon(
                        _isTyping ? Icons.send_rounded : Icons.mic_rounded, 
                        color: Colors.white, 
                        size: 20
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.tajawal(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }
}
