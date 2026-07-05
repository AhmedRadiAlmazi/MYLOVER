import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _newMessages = true;
  bool _occasions = true;
  bool _surprises = true;
  bool _morningMessages = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withOpacity(0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text('الإعدادات ⚙️', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account section
            _SectionTitle('الحساب').animate().fadeIn(),
            _SettingsCard(children: [
              _NavTile(Icons.person_outline, 'تعديل الملف الشخصي', () => context.push('/profile'), AppColors.primary),
              _NavTile(Icons.lock_reset_outlined, 'تغيير كلمة المرور', () {}, AppColors.secondary),
              _NavTile(Icons.security_rounded, 'الأمان والخصوصية', () => context.push('/security'), AppColors.accent),
            ]).animate().slideY().fadeIn(),

            const SizedBox(height: 20),

            // Notifications section
            _SectionTitle('الإشعارات').animate().fadeIn(delay: 100.ms),
            _SettingsCard(children: [
              _SwitchTile(Icons.message_outlined, 'رسائل جديدة', _newMessages, (v) => setState(() => _newMessages = v)),
              _SwitchTile(Icons.celebration_outlined, 'المناسبات والذكريات', _occasions, (v) => setState(() => _occasions = v)),
              _SwitchTile(Icons.card_giftcard_outlined, 'المفاجآت الجديدة', _surprises, (v) => setState(() => _surprises = v)),
              _SwitchTile(Icons.wb_sunny_outlined, 'الرسائل الصباحية', _morningMessages, (v) => setState(() => _morningMessages = v)),
            ]).animate().slideY(delay: 100.ms).fadeIn(delay: 100.ms),

            const SizedBox(height: 20),

            // Backup section
            _SectionTitle('البيانات').animate().fadeIn(delay: 200.ms),
            _SettingsCard(children: [
              _NavTile(Icons.cloud_upload_outlined, 'النسخ الاحتياطي', () {}, AppColors.info),
              _NavTile(Icons.cloud_download_outlined, 'استعادة البيانات', () {}, AppColors.success),
            ]).animate().slideY(delay: 200.ms).fadeIn(delay: 200.ms),

            const SizedBox(height: 20),

            // About section
            _SectionTitle('حول التطبيق').animate().fadeIn(delay: 300.ms),
            _SettingsCard(children: [
              _NavTile(Icons.info_outline_rounded, 'حول كوني أنت', () {}, AppColors.primary),
              _NavTile(Icons.star_border_rounded, 'تقييم التطبيق', () {}, AppColors.accent),
              _NavTile(Icons.share_outlined, 'مشاركة التطبيق', () {}, AppColors.success),
            ]).animate().slideY(delay: 300.ms).fadeIn(delay: 300.ms),

            const SizedBox(height: 24),

            // Version
            Center(
              child: Text(
                'الإصدار 1.0.0',
                style: GoogleFonts.tajawal(color: AppColors.textHint, fontSize: 12),
              ),
            ),

            const SizedBox(height: 24),

            // Logout
            GradientButton(
              text: 'تسجيل الخروج',
              onPressed: () => context.go('/login'),
              gradient: LinearGradient(colors: [AppColors.error.withOpacity(0.8), AppColors.error]),
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.tajawal(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
      child: Column(
        children: children.asMap().entries.map((e) {
          final isLast = e.key == children.length - 1;
          return Column(children: [e.value, if (!isLast) const Divider(height: 1, color: AppColors.divider)]);
        }).toList(),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile(this.icon, this.label, this.onTap, this.iconColor);
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Text(label, style: GoogleFonts.tajawal(color: AppColors.textPrimary, fontSize: 15)),
            const Spacer(),
            const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textHint, size: 14),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile(this.icon, this.label, this.value, this.onChanged);
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: value ? AppColors.primary : AppColors.textHint, size: 22),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: GoogleFonts.tajawal(color: AppColors.textPrimary, fontSize: 15))),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
        ],
      ),
    );
  }
}
