import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/models/app_models.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  DateTime? _relationshipStart;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_relationshipStart == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار تاريخ بداية العلاقة')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final userService = ref.read(userServiceProvider);
      
      final credential = await authService.createUserWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      if (credential.user != null) {
        final newUser = UserModel(
          id: credential.user!.uid,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          relationshipStart: _relationshipStart,
          isOnline: true,
        );
        
        await userService.createUserDocument(newUser);
      }

      if (!mounted) return;
      context.go('/pairing');
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.card,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _relationshipStart) {
      setState(() {
        _relationshipStart = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: AppStrings.register,
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Avatar Picker
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.cardLight,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              size: 50,
                              color: AppColors.textHint,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.secondary,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().scale().fadeIn(),
                    
                    const SizedBox(height: 32),
                    
                    CustomTextField(
                      controller: _nameController,
                      hint: 'الاسم',
                      label: AppStrings.name,
                      prefixIcon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.fieldRequired;
                        }
                        return null;
                      },
                    ).animate().slideX().fadeIn(),
                    
                    const SizedBox(height: 16),
                    
                    CustomTextField(
                      controller: _emailController,
                      hint: 'example@email.com',
                      label: AppStrings.email,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.fieldRequired;
                        }
                        return null;
                      },
                    ).animate().slideX(delay: 50.ms).fadeIn(delay: 50.ms),
                    
                    const SizedBox(height: 16),
                    
                    CustomTextField(
                      controller: _passwordController,
                      hint: '••••••••',
                      label: AppStrings.password,
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.fieldRequired;
                        }
                        if (value.length < 6) {
                          return AppStrings.passwordTooShort;
                        }
                        return null;
                      },
                    ).animate().slideX(delay: 100.ms).fadeIn(delay: 100.ms),
                    
                    const SizedBox(height: 16),
                    
                    CustomTextField(
                      controller: _confirmPasswordController,
                      hint: '••••••••',
                      label: AppStrings.confirmPassword,
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.fieldRequired;
                        }
                        if (value != _passwordController.text) {
                          return AppStrings.passwordsDontMatch;
                        }
                        return null;
                      },
                    ).animate().slideX(delay: 150.ms).fadeIn(delay: 150.ms),
                    
                    const SizedBox(height: 24),
                    
                    // Date Picker
                    Text(
                      AppStrings.relationshipStart,
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 8),
                    
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: AppColors.textHint, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              _relationshipStart == null 
                                  ? 'اختر التاريخ' 
                                  : "${_relationshipStart!.year}/${_relationshipStart!.month}/${_relationshipStart!.day}",
                              style: GoogleFonts.tajawal(
                                color: _relationshipStart == null ? AppColors.textHint : AppColors.textPrimary,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().slideY(delay: 200.ms).fadeIn(delay: 200.ms),
                    
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: GoogleFonts.tajawal(
                          color: AppColors.error,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    
                    const SizedBox(height: 40),
                    
                    GradientButton(
                      text: AppStrings.createAccount,
                      onPressed: _register,
                      isLoading: _isLoading,
                    ).animate().slideY(delay: 250.ms).fadeIn(delay: 250.ms),
                    
                    const SizedBox(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.alreadyHaveAccount,
                          style: GoogleFonts.tajawal(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: Text(
                            AppStrings.login,
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 300.ms),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
