import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/wishes_providers.dart';
import '../models/wish_model.dart';

class WishesScreen extends ConsumerWidget {
  const WishesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishesAsyncValue = ref.watch(wishesStreamProvider);
    final stats = ref.watch(wishesStatsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🌟 أمنياتنا'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Statistics Header
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('الإجمالي', '${stats['total']}', theme),
                _buildStatItem('مكتملة', '${stats['completed']}', theme),
                _buildStatItem('قيد الانتظار', '${stats['pending']}', theme),
                _buildStatItem('الإنجاز', '${stats['percentage'].toStringAsFixed(0)}%', theme),
              ],
            ),
          ),
          
          Expanded(
            child: wishesAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('حدث خطأ: $error')),
              data: (wishes) {
                if (wishes.isEmpty) {
                  return const Center(child: Text('لا توجد أمنيات بعد. ابدأ بإضافة أمنياتكم!'));
                }
                
                final pendingWishes = wishes.where((w) => w.status == WishStatus.pending).toList();
                final completedWishes = wishes.where((w) => w.status == WishStatus.completed).toList();

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (pendingWishes.isNotEmpty) ...[
                      Text('⏳ قيد الانتظار', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...pendingWishes.map((wish) => _buildWishItem(context, wish, theme)),
                      const SizedBox(height: 24),
                    ],
                    if (completedWishes.isNotEmpty) ...[
                      Text('✅ تم تحقيقها', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...completedWishes.map((wish) => _buildWishItem(context, wish, theme)),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/wishes/new');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
      ],
    );
  }

  Widget _buildWishItem(BuildContext context, WishModel wish, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Text(wish.category.emoji, style: const TextStyle(fontSize: 32)),
        title: Text(wish.title, style: TextStyle(
          decoration: wish.status == WishStatus.completed ? TextDecoration.lineThrough : null,
          fontWeight: FontWeight.bold,
        )),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (wish.description.isNotEmpty) Text(wish.description),
            if (wish.targetDate != null)
              Text('الموعد: ${DateFormat('yyyy / MM / dd').format(wish.targetDate!)}', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
          ],
        ),
        trailing: wish.status == WishStatus.pending 
            ? IconButton(
                icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                onPressed: () {
                  context.push('/wishes/complete/${wish.id}');
                },
              )
            : const Icon(Icons.check_circle, color: Colors.green),
        onTap: () {
          // Open details or edit screen
        },
      ),
    );
  }
}
