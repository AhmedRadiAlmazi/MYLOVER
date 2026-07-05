import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../providers/shared_book_providers.dart';

class PageDetailsScreen extends ConsumerWidget {
  final String pageId;

  const PageDetailsScreen({Key? key, required this.pageId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagesAsyncValue = ref.watch(bookPagesStreamProvider);
    final theme = Theme.of(context);

    return pagesAsyncValue.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(body: Center(child: Text('حدث خطأ: $error'))),
      data: (pages) {
        final page = pages.firstWhere((p) => p.id == pageId, orElse: () => throw Exception('Page not found'));

        return Scaffold(
          appBar: AppBar(
            title: const Text('📖 صفحة من كتابنا'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  context.push('/shared-book/page/edit/${page.id}');
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
                    child: ListTile(
                      leading: const Icon(Icons.videocam, color: Colors.blue),
                      title: const Text('مقطع فيديو'),
                      trailing: const Icon(Icons.play_circle_fill),
                      onTap: () {
                        // TODO: Implement video player navigation or dialog
                      },
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
                    child: ListTile(
                      leading: const Icon(Icons.mic, color: Colors.purple),
                      title: const Text('تسجيل صوتي'),
                      trailing: const Icon(Icons.play_arrow),
                      onTap: () {
                        // TODO: Implement audio player
                      },
                    ),
                  )),
                  const SizedBox(height: 32),
                ],
                
                // Likes and Comments Section (Placeholder)
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        page.likes.contains('currentUser') ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        ref.read(sharedBookRepositoryProvider).toggleLike(page.id, 'currentUser');
                      },
                    ),
                    Text('${page.likes.length} إعجاب'),
                    const SizedBox(width: 16),
                    const Icon(Icons.comment_outlined),
                    const SizedBox(width: 4),
                    const Text('التعليقات'),
                  ],
                ),
                const Divider(),
                // Add Comment TextField (simplified)
                TextField(
                  decoration: InputDecoration(
                    hintText: 'أضف تعليقاً جميلاً...',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        // TODO: Implement add comment
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
