import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    
    if (isFirstLaunch) {
      context.go('/onboarding');
      return;
    }

    final authState = ref.read(authStateChangesProvider);
    
    if (authState.value != null) {
      // User is logged in
      final user = ref.read(currentUserProvider).value;
      if (user != null && user.partnerId != null && user.partnerId!.isNotEmpty) {
        context.go('/home');
      } else {
        context.go('/pairing');
      }
    } else {
      // Not logged in
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.deepNightGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Logo
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.5),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.asset(
                  'assets/images/app_logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            )
            .animate()
            .scale(duration: 600.ms, curve: Curves.easeOutBack)
            .fadeIn(duration: 600.ms),
            
            const SizedBox(height: 32),
            
            // App Name
            Text(
              AppStrings.appName,
              style: GoogleFonts.tajawal(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryLight,
              ),
            )
            .animate()
            .fadeIn(delay: 300.ms)
            .slideY(begin: 0.5, end: 0, delay: 300.ms),
            
            const SizedBox(height: 8),
            
            // Tagline
            Text(
              AppStrings.appTagline,
              style: GoogleFonts.tajawal(
                fontSize: 16,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            )
            .animate()
            .fadeIn(delay: 500.ms)
            .slideY(begin: 0.5, end: 0, delay: 500.ms),
            
            const Spacer(),
            
            // Animated Dots
            _AnimatedLoadingDots()
            .animate()
            .fadeIn(delay: 800.ms),
            
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

// ── Animated Loading Dots ────────────────────────────────────────
class _AnimatedLoadingDots extends StatefulWidget {
  @override
  State<_AnimatedLoadingDots> createState() => _AnimatedLoadingDotsState();
}

class _AnimatedLoadingDotsState extends State<_AnimatedLoadingDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );
    _animations = _controllers.map((c) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
    }).toList();

    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 180), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (context, _) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.translate(
                offset: Offset(0, -8 * _animations[i].value),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.secondary,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.5 * _animations[i].value),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
