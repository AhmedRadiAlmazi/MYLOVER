import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/models/app_models.dart';
import '../../../core/services/storage_service.dart';
import '../../auth/providers/auth_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

Future<void> _showEditProfileDialog(BuildContext context, WidgetRef ref, UserModel user) async {
  final nameController = TextEditingController(text: user.name);
  File? selectedImage;
  bool isUploading = false;
  
  await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('تعديل الملف الشخصي', style: GoogleFonts.tajawal(color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
                  if (picked != null) {
                    setState(() => selectedImage = File(picked.path));
                  }
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.background,
                  backgroundImage: selectedImage != null 
                    ? FileImage(selectedImage!) as ImageProvider
                    : (user.avatarUrl != null && user.avatarUrl!.isNotEmpty ? getSmartImageProvider(user.avatarUrl!) : null),
                  child: selectedImage == null && (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                    ? const Icon(Icons.camera_alt_rounded, color: AppColors.primary, size: 30)
                    : null,
                ),
              ),
              const SizedBox(height: 12),
              Text('اضغط لتغيير الصورة', style: GoogleFonts.tajawal(color: AppColors.textHint, fontSize: 12)),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                style: GoogleFonts.tajawal(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'الاسم',
                  labelStyle: GoogleFonts.tajawal(color: AppColors.primary),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isUploading ? null : () => Navigator.pop(ctx, false),
              child: Text('إلغاء', style: GoogleFonts.tajawal(color: AppColors.textHint)),
            ),
            GradientButton(
              text: 'حفظ',
              width: 100,
              height: 40,
              isLoading: isUploading,
              onPressed: isUploading ? () {} : () async {
                if (nameController.text.trim().isEmpty) return;
                
                setState(() => isUploading = true);
                try {
                  String? newAvatarUrl;
                  if (selectedImage != null) {
                    newAvatarUrl = await ref.read(storageServiceProvider).uploadAvatar(selectedImage!, user.id);
                  }
                  
                  final userService = ref.read(userServiceProvider);
                  await userService.updateUserProfile(user.id, nameController.text.trim(), avatarUrl: newAvatarUrl);
                  
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop(true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تحديث الملف الشخصي بنجاح'), backgroundColor: AppColors.success),
                    );
                  }
                } catch (e) {
                  setState(() => isUploading = false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('حدث خطأ أثناء التحديث'), backgroundColor: AppColors.error),
                    );
                  }
                }
              },
            ),
          ],
        );
      }
    ),
  );
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('خطأ: $err', style: const TextStyle(color: Colors.white))),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('لم يتم العثور على بيانات المستخدم', style: TextStyle(color: Colors.white)));
          }

          // Fetch partner data if available
          final partnerAsync = ref.watch(currentPartnerProvider);

          return partnerAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            error: (err, _) => Center(child: Text('خطأ في بيانات الشريك: $err', style: const TextStyle(color: Colors.white))),
            data: (partner) {
              
              // Calculate days together if partner is linked and dates are available
              int daysTogether = 0;
              if (partner != null && user.relationshipStart != null) {
                 daysTogether = DateTime.now().difference(user.relationshipStart!).inDays;
              }

              return CustomScrollView(
                slivers: [
                  // Header with gradient
                  SliverAppBar(
                    expandedHeight: 280,
                    pinned: true,
                    backgroundColor: AppColors.background.withOpacity(0.95),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        }
                      },
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
                        onPressed: () => _showEditProfileDialog(context, ref, user),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(gradient: AppColors.deepNightGradient),
                        child: SafeArea(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Profile Pictures
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // My avatar
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.primary, width: 3),
                                      boxShadow: [BoxShadow(color: AppColors.primaryDark.withOpacity(0.4), blurRadius: 15)],
                                    ),
                                    child: CircleAvatar(
                                      radius: 48,
                                      backgroundColor: AppColors.card,
                                      backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty 
                                        ? getSmartImageProvider(user.avatarUrl!) 
                                        : null,
                                      child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                                        ? Text(
                                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?', 
                                            style: GoogleFonts.tajawal(fontSize: 36, color: AppColors.primary, fontWeight: FontWeight.bold),
                                          )
                                        : null,
                                    ),
                                  ),
                                  
                                  if (partner != null) ...[
                                    // Heart connector
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Column(
                                        children: [
                                          const AnimatedHeart(size: 28, color: AppColors.secondary),
                                          Text('$daysTogether\nيوم', style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 10), textAlign: TextAlign.center),
                                        ],
                                      ),
                                    ),
                                    // Partner avatar
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.secondary, width: 3),
                                        boxShadow: [BoxShadow(color: AppColors.secondaryDark.withOpacity(0.4), blurRadius: 15)],
                                      ),
                                      child: CircleAvatar(
                                        radius: 48,
                                        backgroundColor: AppColors.card,
                                        backgroundImage: partner.avatarUrl != null && partner.avatarUrl!.isNotEmpty 
                                          ? getSmartImageProvider(partner.avatarUrl!) 
                                          : null,
                                        child: partner.avatarUrl == null || partner.avatarUrl!.isEmpty
                                          ? Text(
                                              partner.name.isNotEmpty ? partner.name[0].toUpperCase() : '?', 
                                              style: GoogleFonts.tajawal(fontSize: 36, color: AppColors.secondary, fontWeight: FontWeight.bold),
                                            )
                                          : null,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                partner != null ? '${user.name} & ${partner.name}' : user.name,
                                style: GoogleFonts.tajawal(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              if (user.relationshipStart != null)
                                Text(
                                  'معاً منذ ${user.relationshipStart!.year}/${user.relationshipStart!.month}/${user.relationshipStart!.day}',
                                  style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 13),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // My Info Card
                          Text('ملفي الشخصي', style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)).animate().fadeIn(),
                          const SizedBox(height: 12),
                          _InfoCard(
                            items: [
                              _InfoRow(Icons.person_outline, 'الاسم', user.name),
                              _InfoRow(Icons.email_outlined, 'البريد الإلكتروني', user.email),
                              if (user.relationshipStart != null)
                                _InfoRow(Icons.favorite_border, 'تاريخ بداية العلاقة', '${user.relationshipStart!.year}/${user.relationshipStart!.month}/${user.relationshipStart!.day}'),
                            ],
                          ).animate().slideX().fadeIn(),

                          const SizedBox(height: 24),

                          // Partner Info Card (if linked)
                          if (partner != null) ...[
                            Text('ملف شريكي', style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)).animate().fadeIn(delay: 100.ms),
                            const SizedBox(height: 12),
                            _InfoCard(
                              items: [
                                _InfoRow(Icons.person_outline, 'الاسم', partner.name),
                                _InfoRow(
                                  Icons.circle, 
                                  'الحالة', 
                                  partner.isOnline ? 'متصل الآن 🟢' : 'غير متصل ⚪',
                                ),
                              ],
                            ).animate().slideX(delay: 100.ms).fadeIn(delay: 100.ms),
                            const SizedBox(height: 24),
                          ],

                          // Quick Access
                          Text('وصول سريع', style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)).animate().fadeIn(delay: 200.ms),
                          const SizedBox(height: 12),

                          _QuickAccessTile(Icons.settings_outlined, 'الإعدادات', () => context.push('/settings')),
                          _QuickAccessTile(Icons.security_rounded, 'الأمان والخصوصية', () => context.push('/security')),
                          _QuickAccessTile(Icons.bar_chart_rounded, 'الإحصائيات', () => context.push('/stats')),
                          _QuickAccessTile(Icons.book_outlined, 'كتابنا المشترك', () => context.push('/shared-book')),
                          _QuickAccessTile(Icons.logout_rounded, 'تسجيل الخروج', () {
                            ref.read(authServiceProvider).signOut();
                            context.go('/login');
                          }, color: AppColors.error),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          );
        }
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.items});
  final List<_InfoRow> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final item = entry.value;
          final isLast = entry.key == items.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(item.icon, color: AppColors.primary, size: 20),
                    const SizedBox(width: 16),
                    Text(item.label, style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        item.value, 
                        style: GoogleFonts.tajawal(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis, // Prevents overflow
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1, color: AppColors.divider),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  _InfoRow(this.icon, this.label, this.value);
}

class _QuickAccessTile extends StatelessWidget {
  const _QuickAccessTile(this.icon, this.label, this.onTap, {this.color});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.primary, size: 22),
            const SizedBox(width: 16),
            Text(label, style: GoogleFonts.tajawal(color: color ?? AppColors.textPrimary, fontSize: 15)),
            const Spacer(),
            Icon(Icons.arrow_back_ios_rounded, color: AppColors.textHint, size: 16),
          ],
        ),
      ),
    );
  }
}
