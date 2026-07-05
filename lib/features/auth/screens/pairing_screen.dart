import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/services/user_service.dart';
import '../providers/auth_provider.dart';

final userServiceProvider = Provider((ref) => UserService());

class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key});

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends ConsumerState<PairingScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String _myCode = "------";
  bool _isGenerating = true;
  bool _isGeneratingRequestSent = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _pair() async {
    final partnerCode = _codeController.text.trim().toUpperCase();
    if (partnerCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال الكود المكون من 6 أرقام وحروف')),
      );
      return;
    }
    
    if (partnerCode == _myCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكنك ربط الحساب مع نفسك!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userService = ref.read(userServiceProvider);
      final currentUser = ref.read(currentUserProvider).value;
      
      if (currentUser == null) throw Exception('المستخدم الحالي غير موجود');

      final partner = await userService.getUserByPairingCode(partnerCode);
      
      if (partner == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('عذراً، لم يتم العثور على حساب بهذا الكود')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
      
      // Found partner! Link them.
      await userService.linkWithPartner(currentUser.id, partner.id);
      
      if (!mounted) return;
      
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AnimatedHeart(size: 60),
              const SizedBox(height: 24),
              Text(
                AppStrings.pairingSuccess,
                style: GoogleFonts.tajawal(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'أهلاً بكما في مساحتكما الخاصة',
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pop(); 
        context.go('/home');
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: _myCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الكود بنجاح'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncUser = ref.watch(currentUserProvider);
    
    if (asyncUser.value != null && _isGenerating && !_isGeneratingRequestSent) {
      final userState = asyncUser.value!;
      if (userState.pairingCode != null && userState.pairingCode!.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _myCode = userState.pairingCode!;
              _isGenerating = false;
            });
          }
        });
      } else {
        // Request code generation only once
        WidgetsBinding.instance.addPostFrameCallback((_) {
           if (mounted) {
             setState(() {
               _isGeneratingRequestSent = true;
             });
             
             final userService = ref.read(userServiceProvider);
             userService.generatePairingCode(userState.id).then((code) {
               if (mounted) {
                 setState(() {
                   _myCode = code;
                   _isGenerating = false;
                 });
               }
             }).catchError((e) {
               if (mounted) {
                 setState(() {
                   _isGenerating = false;
                   _isGeneratingRequestSent = false;
                 });
               }
             });
           }
        });
      }
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: '',
        backgroundColor: AppColors.background,
        actions: [
          TextButton(
            onPressed: () {
              ref.read(authServiceProvider).signOut();
              context.go('/login');
            },
            child: Text(
              AppStrings.logout,
              style: GoogleFonts.tajawal(color: AppColors.error),
            ),
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Title Icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondaryContainer.withOpacity(0.3),
                    ),
                    child: const Text('💑', style: TextStyle(fontSize: 60)),
                  ),
                ).animate().scale().fadeIn(),
                
                const SizedBox(height: 24),
                
                Text(
                  AppStrings.pairTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ).animate().slideY().fadeIn(),
                
                const SizedBox(height: 12),
                
                Text(
                  AppStrings.pairDescription,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ).animate().slideY(delay: 100.ms).fadeIn(delay: 100.ms),
                
                const SizedBox(height: 48),
                
                // Your Code Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.yourCode,
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentContainer,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isGenerating)
                            const SizedBox(
                              height: 40,
                              width: 40,
                              child: CircularProgressIndicator(color: Colors.black87),
                            )
                          else
                            Text(
                              _myCode,
                              style: GoogleFonts.tajawal(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 8,
                                color: Colors.black87,
                              ),
                            ),
                          const SizedBox(width: 8),
                          if (!_isGenerating)
                            IconButton(
                              onPressed: _copyCode,
                              icon: const Icon(Icons.copy, color: Colors.black54),
                            ),
                        ],
                      ),
                    ],
                  ),
                ).animate().slideX(delay: 200.ms).fadeIn(delay: 200.ms),
                
                const SizedBox(height: 48),
                
                // Partner Code Section
                Text(
                  AppStrings.enterPartnerCode,
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ).animate().fadeIn(delay: 300.ms),
                
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _codeController,
                  hint: 'مثال: A7X9K2',
                  keyboardType: TextInputType.text,
                  maxLength: 6,
                  prefixIcon: Icons.link,
                ).animate().slideX(delay: 350.ms).fadeIn(delay: 350.ms),
                
                const SizedBox(height: 32),
                
                GradientButton(
                  text: AppStrings.connectWithPartner,
                  onPressed: _pair,
                  isLoading: _isLoading,
                ).animate().slideY(begin: 0.5, delay: 400.ms).fadeIn(delay: 400.ms),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
