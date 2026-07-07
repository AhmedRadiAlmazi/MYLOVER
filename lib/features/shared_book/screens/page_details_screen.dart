import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/shared_book_providers.dart';
import '../models/book_page_comment.dart';
import '../../auth/providers/auth_provider.dart';

class PageDetailsScreen extends ConsumerStatefulWidget {
  final String pageId;

  const PageDetailsScreen({Key? key, required this.pageId}) : super(key: key);

  @override
  ConsumerState<PageDetailsScreen> createState() => _PageDetailsScreenState();
}

class _PageDetailsScreenState extends ConsumerState<PageDetailsScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _playVideoSimulated(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: EdgeInsets.zero,
        content: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                color: Colors.black,
                child: const Center(
                  child: Icon(Icons.videocam_rounded, size: 48, color: Colors.white24),
                ),
              ),
              const Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: LinearProgressIndicator(
                  value: 0.35,
                  color: AppColors.primary,
                  backgroundColor: Colors.white24,
                ),
              ),
              const Icon(Icons.play_arrow_rounded, size: 64, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  void _playAudioSimulated(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('تشغيل التسجيل الصوتي', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(15, (index) {
                final height = (index % 3 == 0) ? 24.0 : (index % 2 == 0) ? 14.0 : 36.0;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 3,
                  height: height,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.replay_10_rounded, color: AppColors.textPrimary), onPressed: () {}),
                Container(
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: IconButton(icon: const Icon(Icons.play_arrow_rounded, color: Colors.white), onPressed: () {}),
                ),
                IconButton(icon: const Icon(Icons.forward_10_rounded, color: AppColors.textPrimary), onPressed: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pagesAsyncValue = ref.watch(bookPagesStreamProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final theme = Theme.of(context);

    return pagesAsyncValue.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(body: Center(child: Text('حدث خطأ: $error'))),
      data: (pages) {
        final page = pages.firstWhere((p) => p.id == widget.pageId, orElse: () => throw Exception('Page not found'));

        return Scaffold(
          appBar: AppBar(
            title: const Text('📖 صفحة من كتابنا'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  context.push('/shared-book/page-edit/${page.id}');
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  page.title,
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('yyyy / MM / dd').format(page.date),
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
                const Divider(height: 32),
                Text(
                  page.content,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 24),
                
                if (page.imageUrls.isNotEmpty) ...[
                  Text(
                    'الصور',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: page.imageUrls.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: page.imageUrls[index].startsWith('http')
                                ? Image.network(
                                    page.imageUrls[index],
                                    width: 300,
                                    fit: BoxFit.cover,
                                  )
                                : Image.memory(
                                    base64Decode(page.imageUrls[index]),
                                    width: 300,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                if (page.videoUrls.isNotEmpty) ...[
                  Text(
                    'الفيديوهات',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...page.videoUrls.map((url) => Card(
                    color: AppColors.card,
                    child: ListTile(
                      leading: const Icon(Icons.videocam, color: Colors.blue),
                      title: const Text('مقطع فيديو', style: TextStyle(color: AppColors.textPrimary)),
                      trailing: const Icon(Icons.play_circle_fill, color: AppColors.primary),
                      onTap: () => _playVideoSimulated(context),
                    ),
                  )),
                  const SizedBox(height: 24),
                ],

                if (page.audioUrls.isNotEmpty) ...[
                  Text(
                    'التسجيلات الصوتية',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...page.audioUrls.map((url) => Card(
                    color: AppColors.card,
                    child: ListTile(
                      leading: const Icon(Icons.mic, color: Colors.purple),
                      title: const Text('تسجيل صوتي', style: TextStyle(color: AppColors.textPrimary)),
                      trailing: const Icon(Icons.play_arrow, color: AppColors.primary),
                      onTap: () => _playAudioSimulated(context),
                    ),
                  )),
                  const SizedBox(height: 32),
                ],
                
                // Likes and Comments Section
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        currentUser != null && page.likes.contains(currentUser.id) ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        if (currentUser != null) {
                          ref.read(sharedBookRepositoryProvider).toggleLike(page.id, currentUser.id);
                        }
                      },
                    ),
                    Text('${page.likes.length} إعجاب', style: GoogleFonts.tajawal(color: AppColors.textPrimary)),
                    const SizedBox(width: 16),
                    const Icon(Icons.comment_outlined, color: AppColors.textPrimary),
                    const SizedBox(width: 4),
                    Text('التعليقات', style: GoogleFonts.tajawal(color: AppColors.textPrimary)),
                  ],
                ),
                const Divider(),
                
                // Display comments stream
                StreamBuilder<List<BookPageComment>>(
                  stream: ref.read(sharedBookRepositoryProvider).getCommentsStream(page.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    }
                    final comments = snapshot.data ?? [];
                    if (comments.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('لا توجد تعليقات بعد.', style: GoogleFonts.tajawal(color: AppColors.textHint)),
                      );
                    }
                    return Column(
                      children: comments.map((c) {
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(c.createdBy, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                          subtitle: Text(c.content, style: GoogleFonts.tajawal(fontSize: 12, color: AppColors.textSecondary)),
                          trailing: Text(DateFormat('jm', 'ar').format(c.createdAt), style: GoogleFonts.tajawal(fontSize: 10, color: AppColors.textHint)),
                        );
                      }).toList(),
                    );
                  },
                ),
                const Divider(),

                // Add Comment TextField
                TextField(
                  controller: _commentController,
                  style: GoogleFonts.tajawal(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'أضف تعليقاً جميلاً...',
                    hintStyle: GoogleFonts.tajawal(color: AppColors.textHint),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: AppColors.primary),
                      onPressed: () async {
                        final text = _commentController.text.trim();
                        if (text.isEmpty || currentUser == null) return;
                        _commentController.clear();
                        
                        final comment = BookPageComment(
                          id: const Uuid().v4(),
                          pageId: page.id,
                          content: text,
                          createdBy: currentUser.name,
                          createdAt: DateTime.now(),
                        );
                        await ref.read(sharedBookRepositoryProvider).addComment(comment);
                      },
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}
