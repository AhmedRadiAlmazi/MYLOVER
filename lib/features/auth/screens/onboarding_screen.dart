import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      title: 'مرحباً بكوني أنت',
      subtitle: 'مساحتكما الخاصة للذكريات\nوالحب — عالم لا يعرفه أحد غيركما',
      icon: Icons.favorite_rounded,
      iconColor: AppColors.secondary,
      gradient: AppColors.twilightGradient,
      particleColor: AppColors.secondary,
    ),
    _OnboardingPage(
      title: 'احتفظوا بذكرياتكم',
      subtitle: 'صور وفيديوهات ورسائل\nلا تُنسى — ألبوم حبكما الخاص',
      icon: Icons.photo_camera_rounded,
      iconColor: AppColors.primary,
      gradient: AppColors.deepNightGradient,
      particleColor: AppColors.primary,
    ),
    _OnboardingPage(
      title: 'تحدثوا بحرية',
      subtitle: 'دردشة آمنة ومشفرة بينكما فقط\nرسائل تصل حتى بعد سنوات',
      icon: Icons.chat_bubble_rounded,
      iconColor: AppColors.info,
      gradient: AppColors.sunsetGradient,
      particleColor: AppColors.info,
    ),
    _OnboardingPage(
      title: 'خصوصية تامة',
      subtitle: 'لا يصل إليه أحد غيركما\nمشفّر بالكامل ومحمي بأمان',
      icon: Icons.lock_rounded,
      iconColor: AppColors.accent,
      gradient: AppColors.cardGradient,
      particleColor: AppColors.accent,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _completeOnboarding() async {
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);
    if (mounted) context.go('/login');
  }

  void _nextPage() {
    HapticFeedback.selectionClick();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Pages
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() => _currentPage = page);
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              final isActive = _currentPage == index;
              return Container(
                decoration: BoxDecoration(gradient: page.gradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),

                        // ── Icon with floating + particle effect ──
                        AnimatedBuilder(
                          animation: _floatAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, isActive ? _floatAnimation.value : 0),
                              child: child,
                            );
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer glow ring
                              Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: page.particleColor.withOpacity(0.08),
                                  border: Border.all(
                                    color: page.particleColor.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              // Mid ring
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: page.particleColor.withOpacity(0.12),
                                  border: Border.all(
                                    color: page.particleColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                              ),
                              // Icon container
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      page.particleColor.withOpacity(0.9),
                                      page.particleColor.withOpacity(0.5),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: page.particleColor.withOpacity(0.5),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  page.icon,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                              // Orbiting particles
                              if (isActive) ...[
                                _OrbitingDot(color: page.particleColor, angle: 0, radius: 88),
                                _OrbitingDot(color: page.particleColor, angle: math.pi * 0.7, radius: 88),
                                _OrbitingDot(color: page.particleColor, angle: math.pi * 1.4, radius: 88),
                              ],
                            ],
                          ),
                        )
                        .animate(target: isActive ? 1 : 0)
                        .scale(
                          begin: const Offset(0.7, 0.7),
                          end: const Offset(1.0, 1.0),
                          duration: 500.ms,
                          curve: Curves.easeOutBack,
                        )
                        .fadeIn(duration: 400.ms),

                        const Spacer(flex: 1),

                        // ── Title ──
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.tajawal(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                            shadows: [
                              Shadow(
                                color: page.particleColor.withOpacity(0.5),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        )
                        .animate(target: isActive ? 1 : 0)
                        .slideY(begin: 0.4, end: 0, duration: 400.ms, curve: Curves.easeOut)
                        .fadeIn(duration: 400.ms),

                        const SizedBox(height: 20),

                        // ── Subtitle ──
                        Text(
                          page.subtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.75),
                            height: 1.8,
                          ),
                        )
                        .animate(target: isActive ? 1 : 0)
                        .slideY(begin: 0.4, end: 0, duration: 400.ms, delay: 100.ms, curve: Curves.easeOut)
                        .fadeIn(duration: 400.ms, delay: 100.ms),

                        const Spacer(flex: 3),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // ── Bottom Controls ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(28, 40, 28, 0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.0, 1.0],
                  colors: [
                    AppColors.background.withOpacity(0.95),
                    AppColors.background.withOpacity(0.0),
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    // Dots
                    DotsIndicator(
                      count: _pages.length,
                      currentIndex: _currentPage,
                    ),
                    const SizedBox(height: 28),

                    Row(
                      children: [
                        // Skip button
                        AnimatedOpacity(
                          opacity: _currentPage < _pages.length - 1 ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: TextButton(
                            onPressed: _completeOnboarding,
                            child: Text(
                              AppStrings.skip,
                              style: GoogleFonts.tajawal(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Next / Start button
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: _currentPage == _pages.length - 1 ? 200 : 130,
                          child: GradientButton(
                            text: _currentPage == _pages.length - 1
                                ? AppStrings.getStarted
                                : AppStrings.next,
                            onPressed: _nextPage,
                            // RTL correct: forward in Arabic is → (left arrow icon)
                            icon: _currentPage == _pages.length - 1
                                ? Icons.rocket_launch_rounded
                                : Icons.arrow_forward_ios_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Orbiting Dot Widget ──────────────────────────────────────────
class _OrbitingDot extends StatefulWidget {
  final Color color;
  final double angle;
  final double radius;

  const _OrbitingDot({
    required this.color,
    required this.angle,
    required this.radius,
  });

  @override
  State<_OrbitingDot> createState() => _OrbitingDotState();
}

class _OrbitingDotState extends State<_OrbitingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final angle = widget.angle + _ctrl.value * 2 * math.pi;
        return Transform.translate(
          offset: Offset(
            widget.radius * math.cos(angle),
            widget.radius * math.sin(angle),
          ),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.7),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Data Model ──────────────────────────────────────────────────
class _OnboardingPage {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final LinearGradient gradient;
  final Color particleColor;

  _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.gradient,
    required this.particleColor,
  });
}
