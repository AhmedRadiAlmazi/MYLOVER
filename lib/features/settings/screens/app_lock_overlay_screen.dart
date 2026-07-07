import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';

class AppLockOverlayScreen extends StatefulWidget {
  const AppLockOverlayScreen({super.key, required this.onUnlocked});
  final VoidCallback onUnlocked;

  @override
  State<AppLockOverlayScreen> createState() => _AppLockOverlayScreenState();
}

class _AppLockOverlayScreenState extends State<AppLockOverlayScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final List<TextEditingController> _controllers = List.generate(4, (i) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (i) => FocusNode());
  
  bool _useBiometric = false;
  bool _usePin = false;
  String _savedPin = '';
  bool _isAuthenticating = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkLockSettings();
  }

  Future<void> _checkLockSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _useBiometric = prefs.getBool('security_biometric') ?? false;
    _usePin = prefs.getBool('security_pin') ?? false;
    _savedPin = prefs.getString('security_pin_code') ?? '';

    if (!_useBiometric && !_usePin) {
      // Security is disabled
      widget.onUnlocked();
      return;
    }

    if (_useBiometric) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _authenticateBiometric();
      });
    } else if (_usePin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[0].requestFocus();
      });
    }
  }

  Future<void> _authenticateBiometric() async {
    if (_isAuthenticating) return;
    setState(() {
      _isAuthenticating = true;
      _errorMessage = '';
    });

    try {
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (!canAuthenticate) {
        setState(() {
          _isAuthenticating = false;
          _errorMessage = 'التحقق الحيوي غير متاح على هذا الجهاز';
        });
        if (_usePin) _focusNodes[0].requestFocus();
        return;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'قم بتأكيد البصمة لفتح تطبيق كوني أنت',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      setState(() => _isAuthenticating = false);

      if (authenticated) {
        HapticFeedback.mediumImpact();
        widget.onUnlocked();
      } else {
        setState(() {
          _errorMessage = 'فشل التحقق من البصمة';
        });
        if (_usePin) _focusNodes[0].requestFocus();
      }
    } catch (e) {
      setState(() {
        _isAuthenticating = false;
        _errorMessage = 'خطأ أثناء التحقق: $e';
      });
      if (_usePin) _focusNodes[0].requestFocus();
    }
  }

  void _onPinChanged(String value, int index) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Verify when completed
    final code = _controllers.map((c) => c.text).join();
    if (code.length == 4) {
      if (code == _savedPin) {
        HapticFeedback.mediumImpact();
        widget.onUnlocked();
      } else {
        HapticFeedback.vibrate();
        setState(() {
          _errorMessage = 'رمز PIN غير صحيح';
          for (var c in _controllers) {
            c.clear();
          }
        });
        _focusNodes[0].requestFocus();
      }
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080810),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                  ),
                  child: const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 48),
                ),
                const SizedBox(height: 24),
                Text(
                  'التطبيق مقفل 🔒',
                  style: GoogleFonts.tajawal(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _usePin ? 'الرجاء إدخال رمز PIN للمتابعة' : 'الرجاء التحقق من بصمة الإصبع للمتابعة',
                  style: GoogleFonts.tajawal(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 36),

                // PIN Entry fields
                if (_usePin)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) => Container(
                      width: 52,
                      height: 52,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.card,
                      ),
                      child: TextField(
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        maxLength: 1,
                        obscureText: true,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: GoogleFonts.tajawal(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
                        onChanged: (value) => _onPinChanged(value, i),
                      ),
                    )),
                  ),

                const SizedBox(height: 24),

                // Error Message
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage,
                      style: GoogleFonts.tajawal(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Biometrics retry button
                if (_useBiometric)
                  IconButton(
                    iconSize: 64,
                    icon: const Icon(Icons.fingerprint_rounded, color: AppColors.primary),
                    onPressed: _authenticateBiometric,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
