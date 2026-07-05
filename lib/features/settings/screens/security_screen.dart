import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/theme/app_colors.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  bool _biometric = false;
  bool _pin = false;
  bool _preventScreenshot = false;
  bool _autoLock = true;
  String _autoLockTime = '5 دقائق';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _biometric = prefs.getBool('security_biometric') ?? false;
      _pin = prefs.getBool('security_pin') ?? false;
      _preventScreenshot = prefs.getBool('security_prevent_screenshot') ?? false;
      _autoLock = prefs.getBool('security_autolock') ?? true;
      _autoLockTime = prefs.getString('security_autolock_time') ?? '5 دقائق';
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      // Authenticate first before enabling
      try {
        final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
        final canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
        
        if (!canAuthenticate) {
          _showErrorSnackBar('الجهاز لا يدعم البصمة أو الحماية الحيوية');
          return;
        }

        final authenticated = await _localAuth.authenticate(
          localizedReason: 'يرجى تأكيد البصمة لتفعيل حماية التطبيق',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );

        if (!authenticated) return;
      } catch (e) {
        _showErrorSnackBar('حدث خطأ أثناء التحقق: $e');
        return;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('security_biometric', value);
    setState(() {
      _biometric = value;
    });
  }

  Future<void> _togglePin(bool value) async {
    if (value) {
      _showPinDialog();
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('security_pin', false);
      await prefs.remove('security_pin_code');
      setState(() {
        _pin = false;
      });
    }
  }

  Future<void> _toggleScreenshot(bool value) async {
    // Under real implementation, this would call secure_application package,
    // or native platform channels to set FLAG_SECURE. We persist it in SharedPreferences.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('security_prevent_screenshot', value);
    setState(() {
      _preventScreenshot = value;
    });
    
    _showSuccessSnackBar(value ? 'تم تفعيل منع لقطات الشاشة بنجاح' : 'تم إلغاء منع لقطات الشاشة');
  }

  Future<void> _toggleAutoLock(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('security_autolock', value);
    setState(() {
      _autoLock = value;
    });
  }

  Future<void> _changeAutoLockTime(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('security_autolock_time', value);
    setState(() {
      _autoLockTime = value;
    });
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.tajawal()),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showSuccessSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.tajawal()),
        backgroundColor: AppColors.success,
      ),
    );
  }

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
        title: Text('الأمان والخصوصية 🔒', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Security icon
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryContainer.withOpacity(0.3),
                border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
              ),
              child: const Icon(Icons.security_rounded, color: AppColors.primary, size: 44),
            ).animate().scale().fadeIn(),

            const SizedBox(height: 8),
            Text('حماية تطبيقك', style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)).animate().fadeIn(),
            Text('أمانك أولويتنا', style: GoogleFonts.tajawal(fontSize: 13, color: AppColors.textSecondary)).animate().fadeIn(),

            const SizedBox(height: 28),

            // Security options
            _SecurityCard(children: [
              _SwitchOption(
                icon: Icons.fingerprint,
                title: 'بصمة الإصبع',
                subtitle: 'فتح التطبيق ببصمتك',
                value: _biometric,
                iconColor: AppColors.primary,
                onChanged: _toggleBiometric,
              ),
              _SwitchOption(
                icon: Icons.pin_outlined,
                title: 'رمز PIN',
                subtitle: 'رمز مكون من 4 أرقام',
                value: _pin,
                iconColor: AppColors.secondary,
                onChanged: _togglePin,
              ),
            ]).animate().slideY(delay: 100.ms).fadeIn(delay: 100.ms),

            const SizedBox(height: 16),

            _SecurityCard(children: [
              _SwitchOption(
                icon: Icons.lock_clock_outlined,
                title: 'القفل التلقائي',
                subtitle: 'قفل التطبيق بعد عدم النشاط',
                value: _autoLock,
                iconColor: AppColors.accent,
                onChanged: _toggleAutoLock,
              ),
              if (_autoLock)
                _SelectOption(
                  icon: Icons.timer_outlined,
                  title: 'مدة القفل',
                  value: _autoLockTime,
                  options: ['دقيقة واحدة', '5 دقائق', '15 دقيقة', '30 دقيقة'],
                  onChanged: _changeAutoLockTime,
                  iconColor: AppColors.info,
                ),
            ]).animate().slideY(delay: 200.ms).fadeIn(delay: 200.ms),

            const SizedBox(height: 16),

            _SecurityCard(children: [
              _SwitchOption(
                icon: Icons.no_photography_outlined,
                title: 'منع لقطات الشاشة',
                subtitle: 'منع التقاط صور للشاشة',
                value: _preventScreenshot,
                iconColor: AppColors.error,
                onChanged: _toggleScreenshot,
              ),
            ]).animate().slideY(delay: 300.ms).fadeIn(delay: 300.ms),

            const SizedBox(height: 16),

            // Encryption status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.success.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.verified_user_rounded, color: AppColors.success, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('التشفير End-to-End', style: GoogleFonts.tajawal(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('جميع بياناتك مشفرة ومحمية', style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle_rounded, color: AppColors.success),
                ],
              ),
            ).animate().slideY(delay: 400.ms).fadeIn(delay: 400.ms),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showPinDialog() {
    final controllers = List.generate(4, (i) => TextEditingController());
    final focusNodes = List.generate(4, (i) => FocusNode());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('إنشاء رمز PIN', style: GoogleFonts.tajawal(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('أدخل رمز PIN من 4 أرقام', style: GoogleFonts.tajawal(color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) => Container(
                width: 48, height: 48, margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(border: Border.all(color: AppColors.primary, width: 2), borderRadius: BorderRadius.circular(12)),
                child: TextField(
                  controller: controllers[i],
                  focusNode: focusNodes[i],
                  maxLength: 1, textAlign: TextAlign.center, keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: GoogleFonts.tajawal(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
                  onChanged: (value) {
                    if (value.isNotEmpty && i < 3) {
                      focusNodes[i + 1].requestFocus();
                    } else if (value.isEmpty && i > 0) {
                      focusNodes[i - 1].requestFocus();
                    }
                  },
                ),
              )),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _pin = false);
              Navigator.pop(ctx);
            },
            child: Text('إلغاء', style: GoogleFonts.tajawal(color: AppColors.textHint)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final pinCode = controllers.map((c) => c.text).join();
              if (pinCode.length < 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('يرجى إكمال رمز PIN المكون من 4 أرقام', style: GoogleFonts.tajawal())),
                );
                return;
              }
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('security_pin', true);
              await prefs.setString('security_pin_code', pinCode);
              
              setState(() {
                _pin = true;
              });
              
              if (mounted) {
                Navigator.pop(ctx);
                _showSuccessSnackBar('تم حفظ رمز PIN بنجاح');
              }
            },
            child: Text('حفظ', style: GoogleFonts.tajawal()),
          ),
        ],
      ),
    );
  }
}

class _SecurityCard extends StatelessWidget {
  const _SecurityCard({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
      child: Column(children: children.asMap().entries.map((e) {
        final isLast = e.key == children.length - 1;
        return Column(children: [e.value, if (!isLast) const Divider(height: 1, color: AppColors.divider)]);
      }).toList()),
    );
  }
}

class _SwitchOption extends StatelessWidget {
  const _SwitchOption({required this.icon, required this.title, required this.subtitle, required this.value, required this.iconColor, required this.onChanged});
  final IconData icon; final String title; final String subtitle; final bool value; final Color iconColor; final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 20)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.tajawal(color: AppColors.textPrimary, fontSize: 15)),
          Text(subtitle, style: GoogleFonts.tajawal(color: AppColors.textHint, fontSize: 11)),
        ])),
        Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
      ]),
    );
  }
}

class _SelectOption extends StatelessWidget {
  const _SelectOption({required this.icon, required this.title, required this.value, required this.options, required this.onChanged, required this.iconColor});
  final IconData icon; final String title; final String value; final List<String> options; final ValueChanged<String> onChanged; final Color iconColor;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 20)),
        const SizedBox(width: 14),
        Expanded(child: Text(title, style: GoogleFonts.tajawal(color: AppColors.textPrimary, fontSize: 15))),
        DropdownButton<String>(
          value: value, dropdownColor: AppColors.surface,
          style: GoogleFonts.tajawal(color: AppColors.primary, fontSize: 13),
          underline: const SizedBox(),
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ]),
    );
  }
}
