import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../services/secret_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Providers
// ─────────────────────────────────────────────────────────────────────────────
final secretServiceProvider =
    Provider<SecretService>((ref) => SecretService());

final secretsStreamProvider =
    StreamProvider<List<SecretModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null ||
      user.partnerId == null ||
      user.partnerId!.isEmpty) {
    return Stream.value([]);
  }
  return ref
      .watch(secretServiceProvider)
      .getSecretsStream(user.id, user.partnerId!);
});

// ─────────────────────────────────────────────────────────────────────────────
//  SecretBoxScreen
// ─────────────────────────────────────────────────────────────────────────────
class SecretBoxScreen extends ConsumerStatefulWidget {
  const SecretBoxScreen({super.key});

  @override
  ConsumerState<SecretBoxScreen> createState() => _SecretBoxScreenState();
}

class _SecretBoxScreenState extends ConsumerState<SecretBoxScreen> {
  bool _isUnlocked = false;
  bool _isUnlocking = false;

  // ── Lock / Unlock ──────────────────────────────────────────────
  Future<void> _unlock() async {
    HapticFeedback.mediumImpact();
    setState(() => _isUnlocking = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _isUnlocking = false;
        _isUnlocked = true;
      });
    }
  }

  // ── Add Secret Dialog ──────────────────────────────────────────
  void _showAddSecretDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddSecretSheet(
        onSave: (title, content, images) async {
          final user = ref.read(currentUserProvider).value;
          if (user == null || user.partnerId == null) return;

          final secretId = const Uuid().v4();
          final service = ref.read(secretServiceProvider);

          // Convert images directly to base64 data URLs
          List<String> imageUrls = [];
          if (images.isNotEmpty) {
            imageUrls = await service.convertMultipleToBase64(images);
          }

          // Save secret to firestore
          final newSecret = SecretModel(
            id: secretId,
            title: title,
            content: content,
            createdAt: DateTime.now(),
            ownerId: user.id,
            imageUrls: imageUrls,
          );
          await service.addSecret(
            secret: newSecret,
            userId: user.id,
            partnerId: user.partnerId!,
          );
        },
      ),
    );
  }

  // ── Delete Secret ──────────────────────────────────────────────
  Future<void> _deleteSecret(String secretId) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null || user.partnerId == null) return;
    await ref.read(secretServiceProvider).deleteSecret(
          secretId: secretId,
          userId: user.id,
          partnerId: user.partnerId!,
        );
  }

  // ── Build ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withOpacity(0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'الصندوق السري',
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isUnlocked) ...[
            IconButton(
              icon: const Icon(Icons.add_rounded, color: AppColors.primary, size: 28),
              tooltip: 'إضافة سر',
              onPressed: _showAddSecretDialog,
            ),
            IconButton(
              icon: const Icon(Icons.lock_rounded, color: AppColors.error),
              tooltip: 'قفل الصندوق',
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() => _isUnlocked = false);
              },
            ),
          ]
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _isUnlocked
            ? _buildContent()
            : _buildLockScreen(),
      ),
    );
  }

  // ── Lock Screen ────────────────────────────────────────────────
  Widget _buildLockScreen() {
    return Center(
      key: const ValueKey('locked'),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    AppColors.secondary.withOpacity(0.2),
                  ],
                ),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.4), width: 2),
              ),
              child: const Icon(Icons.lock_rounded,
                  color: AppColors.primary, size: 64),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .shimmer(duration: 2000.ms, color: AppColors.primary.withOpacity(0.3)),
            const SizedBox(height: 28),
            Text(
              'الصندوق السري',
              style: GoogleFonts.tajawal(
                color: AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(),
            const SizedBox(height: 12),
            Text(
              'مساحتك الخاصة للصور والذكريات السرية.\nفقط أنت يمكنك الوصول إليها.',
              style: GoogleFonts.tajawal(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.7,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 48),
            GradientButton(
              text: _isUnlocking ? 'جارٍ الفتح...' : '🔓  فتح الصندوق',
              onPressed: _unlock,
              isLoading: _isUnlocking,
              width: 220,
            ).animate().slideY(delay: 200.ms).fadeIn(delay: 200.ms),
          ],
        ),
      ),
    );
  }

  // ── Content ────────────────────────────────────────────────────
  Widget _buildContent() {
    final secretsAsync = ref.watch(secretsStreamProvider);

    return CustomScrollView(
      key: const ValueKey('unlocked'),
      slivers: [
        // ── Unlocked banner
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_open_rounded,
                      color: AppColors.success),
                  const SizedBox(width: 12),
                  Text(
                    'مرحباً! الصندوق مفتوح 🎉',
                    style: GoogleFonts.tajawal(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ).animate().slideY().fadeIn(),
          ),
        ),

        // ── Secrets list
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          sliver: secretsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (err, _) => SliverToBoxAdapter(
              child: Center(
                child: Text(
                  'خطأ: $err',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ),
            data: (secrets) {
              if (secrets.isEmpty) {
                return SliverToBoxAdapter(
                  child: _EmptySecretsView(onAdd: _showAddSecretDialog),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _SecretCard(
                    secret: secrets[index],
                    index: index,
                    onDelete: () => _deleteSecret(secrets[index].id),
                  ),
                  childCount: secrets.length,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _SecretCard
// ─────────────────────────────────────────────────────────────────────────────
class _SecretCard extends StatelessWidget {
  const _SecretCard({
    required this.secret,
    required this.index,
    required this.onDelete,
  });

  final SecretModel secret;
  final int index;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final hasImages = secret.imageUrls.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openDetail(context),
          onLongPress: () => _showDeleteDialog(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image preview strip (if any) ──────────────────
              if (hasImages)
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: SizedBox(
                    height: 140,
                    child: _ImageStrip(
                      imageUrls: secret.imageUrls,
                      onTap: (startIndex) =>
                          _openGallery(context, startIndex),
                    ),
                  ),
                ),

              // ── Text area ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.12),
                      ),
                      child: const Icon(Icons.security_rounded,
                          color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            secret.title,
                            style: GoogleFonts.tajawal(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          if (secret.content.isNotEmpty)
                            Text(
                              secret.content,
                              style: GoogleFonts.tajawal(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded,
                                  size: 12,
                                  color: AppColors.textHint),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(secret.createdAt),
                                style: GoogleFonts.tajawal(
                                  color: AppColors.textHint,
                                  fontSize: 11,
                                ),
                              ),
                              if (hasImages) ...[
                                const SizedBox(width: 10),
                                Icon(Icons.photo_library_rounded,
                                    size: 12,
                                    color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  '${secret.imageUrls.length} صورة',
                                  style: GoogleFonts.tajawal(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_left_rounded,
                        color: AppColors.textHint),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .slideY(
          begin: 0.15,
          delay: Duration(milliseconds: index * 80),
          duration: 400.ms,
          curve: Curves.easeOut,
        )
        .fadeIn(delay: Duration(milliseconds: index * 80));
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';

  void _openDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _SecretDetailScreen(secret: secret),
      ),
    );
  }

  void _openGallery(BuildContext context, int startIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _SecretGalleryViewer(
          imageUrls: secret.imageUrls,
          initialIndex: startIndex,
          title: secret.title,
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'حذف السر',
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'هل تريد حذف هذا السر وصوره نهائياً؟',
          style: GoogleFonts.tajawal(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء',
                style: GoogleFonts.tajawal(color: AppColors.textHint)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            child: Text('حذف',
                style: GoogleFonts.tajawal(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _ImageStrip — horizontal scrollable image preview
// ─────────────────────────────────────────────────────────────────────────────
class _ImageStrip extends StatelessWidget {
  const _ImageStrip({required this.imageUrls, required this.onTap});

  final List<String> imageUrls;
  final void Function(int startIndex) onTap;

  @override
  Widget build(BuildContext context) {
    if (imageUrls.length == 1) {
      return GestureDetector(
        onTap: () => onTap(0),
        child: SmartImage(
          imageUrl: imageUrls[0],
          width: double.infinity,
          height: 140,
          fit: BoxFit.cover,
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: imageUrls.length,
      itemBuilder: (context, i) => GestureDetector(
        onTap: () => onTap(i),
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 2),
              width: 130,
              child: SmartImage(
                imageUrl: imageUrls[i],
                fit: BoxFit.cover,
              ),
            ),
            // Count overlay on last visible item
            if (i == 2 && imageUrls.length > 3)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.55),
                  alignment: Alignment.center,
                  child: Text(
                    '+${imageUrls.length - 3}',
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _SecretDetailScreen
// ─────────────────────────────────────────────────────────────────────────────
class _SecretDetailScreen extends ConsumerStatefulWidget {
  const _SecretDetailScreen({required this.secret});
  final SecretModel secret;

  @override
  ConsumerState<_SecretDetailScreen> createState() =>
      _SecretDetailScreenState();
}

class _SecretDetailScreenState
    extends ConsumerState<_SecretDetailScreen> {
  late SecretModel _secret;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _secret = widget.secret;
  }

  Future<void> _addImages(ImageSource source) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null || user.partnerId == null) return;

    final service = ref.read(secretServiceProvider);
    final picked = await service.pickImages(source: source);
    if (picked.isEmpty) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final newUrls = await service.convertMultipleToBase64(picked);

      final allUrls = [..._secret.imageUrls, ...newUrls];
      await service.updateSecretImages(
        secretId: _secret.id,
        imageUrls: allUrls,
        userId: user.id,
        partnerId: user.partnerId!,
      );

      setState(() => _secret = _secret.copyWith(imageUrls: allUrls));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في معالجة الصور: $e',
                style: GoogleFonts.tajawal()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'إضافة صور سرية',
                style: GoogleFonts.tajawal(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SourceButton(
                    icon: Icons.photo_library_rounded,
                    label: 'المعرض',
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.pop(context);
                      _addImages(ImageSource.gallery);
                    },
                  ),
                  _SourceButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'الكاميرا',
                    color: AppColors.secondary,
                    onTap: () {
                      Navigator.pop(context);
                      _addImages(ImageSource.camera);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteImage(int index) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null || user.partnerId == null) return;

    final newUrls = [..._secret.imageUrls]..removeAt(index);
    await ref.read(secretServiceProvider).updateSecretImages(
          secretId: _secret.id,
          imageUrls: newUrls,
          userId: user.id,
          partnerId: user.partnerId!,
        );
    setState(() => _secret = _secret.copyWith(imageUrls: newUrls));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _secret.title,
          style: GoogleFonts.tajawal(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_rounded,
                color: AppColors.primary),
            tooltip: 'إضافة صور',
            onPressed: _showImageSourcePicker,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // ── Upload/Processing progress
          if (_isUploading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    const LinearProgressIndicator(
                      backgroundColor: AppColors.cardLight,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      minHeight: 4,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'جارٍ معالجة وتشفير الصور...',
                      style: GoogleFonts.tajawal(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

          // ── Content field
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_secret.content.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.15)),
                      ),
                      child: Text(
                        _secret.content,
                        style: GoogleFonts.tajawal(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          height: 1.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Photos section
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'الصور السرية',
                        style: GoogleFonts.tajawal(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_secret.imageUrls.length} صورة',
                        style: GoogleFonts.tajawal(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── Images grid
          if (_secret.imageUrls.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.lock_outline,
                        size: 64,
                        color: AppColors.textHint.withOpacity(0.4)),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد صور بعد\nاضغط على إضافة صور لإرفاقها بالسر',
                      style: GoogleFonts.tajawal(
                        color: AppColors.textHint,
                        fontSize: 14,
                        height: 1.7,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _SecretImageTile(
                    url: _secret.imageUrls[index],
                    index: index,
                    total: _secret.imageUrls.length,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _SecretGalleryViewer(
                          imageUrls: _secret.imageUrls,
                          initialIndex: index,
                          title: _secret.title,
                        ),
                      ),
                    ),
                    onDelete: () => _deleteImage(index),
                  ),
                  childCount: _secret.imageUrls.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showImageSourcePicker,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_photo_alternate_rounded,
            color: Colors.white),
        label: Text('إضافة صور',
            style: GoogleFonts.tajawal(color: Colors.white)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _SecretImageTile
// ─────────────────────────────────────────────────────────────────────────────
class _SecretImageTile extends StatelessWidget {
  const _SecretImageTile({
    required this.url,
    required this.index,
    required this.total,
    required this.onTap,
    required this.onDelete,
  });

  final String url;
  final int index;
  final int total;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        HapticFeedback.mediumImpact();
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.card,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Text('حذف الصورة',
                style: GoogleFonts.tajawal(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold)),
            content: Text('هل تريد حذف هذه الصورة؟',
                style: GoogleFonts.tajawal(
                    color: AppColors.textSecondary)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('إلغاء',
                    style: GoogleFonts.tajawal(
                        color: AppColors.textHint)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  onDelete();
                },
                child: Text('حذف',
                    style: GoogleFonts.tajawal(
                        color: AppColors.error)),
              ),
            ],
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SmartImage(
          imageUrl: url,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _SecretGalleryViewer — full-screen photo_view gallery
// ─────────────────────────────────────────────────────────────────────────────
class _SecretGalleryViewer extends StatefulWidget {
  const _SecretGalleryViewer({
    required this.imageUrls,
    required this.initialIndex,
    required this.title,
  });

  final List<String> imageUrls;
  final int initialIndex;
  final String title;

  @override
  State<_SecretGalleryViewer> createState() => _SecretGalleryViewerState();
}

class _SecretGalleryViewerState extends State<_SecretGalleryViewer> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.6),
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.title} (${_currentIndex + 1}/${widget.imageUrls.length})',
          style: GoogleFonts.tajawal(color: Colors.white, fontSize: 16),
        ),
      ),
      body: PhotoViewGallery.builder(
        itemCount: widget.imageUrls.length,
        pageController:
            PageController(initialPage: widget.initialIndex),
        onPageChanged: (i) => setState(() => _currentIndex = i),
        builder: (context, index) => PhotoViewGalleryPageOptions(
          imageProvider: getSmartImageProvider(widget.imageUrls[index]),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 3,
          heroAttributes: PhotoViewHeroAttributes(
              tag: 'secret_img_${widget.imageUrls[index]}'),
        ),
        loadingBuilder: (_, __) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _AddSecretSheet — bottom sheet for creating a new secret
// ─────────────────────────────────────────────────────────────────────────────
class _AddSecretSheet extends StatefulWidget {
  const _AddSecretSheet({required this.onSave});

  final Future<void> Function(
      String title, String content, List<XFile> images) onSave;

  @override
  State<_AddSecretSheet> createState() => _AddSecretSheetState();
}

class _AddSecretSheetState extends State<_AddSecretSheet> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final List<XFile> _pickedImages = [];
  bool _isSaving = false;

  Future<void> _pickFromGallery() async {
    final service = SecretService();
    final images = await service.pickImages(source: ImageSource.gallery);
    if (images.isNotEmpty) setState(() => _pickedImages.addAll(images));
  }

  Future<void> _pickFromCamera() async {
    final service = SecretService();
    final images = await service.pickImages(source: ImageSource.camera);
    if (images.isNotEmpty) setState(() => _pickedImages.addAll(images));
  }

  void _removeImage(int index) =>
      setState(() => _pickedImages.removeAt(index));

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await widget.onSave(
        _titleCtrl.text.trim(),
        _contentCtrl.text.trim(),
        _pickedImages,
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'سر جديد 🤫',
              style: GoogleFonts.tajawal(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Title
            _SheetTextField(
              controller: _titleCtrl,
              hint: 'عنوان السر...',
              icon: Icons.title_rounded,
            ),
            const SizedBox(height: 12),

            // Content
            _SheetTextField(
              controller: _contentCtrl,
              hint: 'اكتب ما تود إخفاءه...',
              icon: Icons.edit_note_rounded,
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            // Image picker row
            Row(
              children: [
                Text(
                  'الصور',
                  style: GoogleFonts.tajawal(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                _SmallPickButton(
                  icon: Icons.photo_library_rounded,
                  label: 'المعرض',
                  onTap: _pickFromGallery,
                ),
                const SizedBox(width: 8),
                _SmallPickButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'كاميرا',
                  onTap: _pickFromCamera,
                ),
              ],
            ),

            // Preview of picked images
            if (_pickedImages.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _pickedImages.length,
                  itemBuilder: (context, i) => Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(File(_pickedImages[i].path)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => _removeImage(i),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black87,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(3),
                            child: const Icon(Icons.close_rounded,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Save button
            GradientButton(
              text: _isSaving
                  ? 'جارٍ الحفظ...'
                  : 'حفظ السر${_pickedImages.isNotEmpty ? " (${_pickedImages.length} صور)" : ""}',
              onPressed: _isSaving ? () {} : _save,
              isLoading: _isSaving,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Helper widgets ───────────────────────────────────────────────────────────

class _SheetTextField extends StatelessWidget {
  const _SheetTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
  });
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: GoogleFonts.tajawal(color: AppColors.textPrimary),
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.tajawal(color: AppColors.textHint),
        prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _SmallPickButton extends StatelessWidget {
  const _SmallPickButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: AppColors.primary.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.tajawal(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.tajawal(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySecretsView extends StatelessWidget {
  const _EmptySecretsView({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(Icons.lock_outline,
              size: 80,
              color: AppColors.textHint.withOpacity(0.3)),
          const SizedBox(height: 20),
          Text(
            'لا توجد أسرار بعد',
            style: GoogleFonts.tajawal(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أضف سرك الأول — نصاً أو صوراً أو كليهما',
            style: GoogleFonts.tajawal(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          GradientButton(
            text: 'إضافة سر جديد +',
            onPressed: onAdd,
            width: 200,
          ),
        ],
      ),
    );
  }
}
