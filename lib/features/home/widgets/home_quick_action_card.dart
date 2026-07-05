import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

class HomeQuickActionCard extends StatefulWidget {
  const HomeQuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.gradient = AppColors.cardGradient,
    this.glowColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final LinearGradient gradient;
  final Color? glowColor;

  @override
  State<HomeQuickActionCard> createState() => _HomeQuickActionCardState();
}

class _HomeQuickActionCardState extends State<HomeQuickActionCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glow = widget.glowColor ?? AppColors.primary;
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _shimmerController.forward(from: 0);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: glow.withOpacity(_isPressed ? 0.5 : 0.25),
                blurRadius: _isPressed ? 20 : 10,
                spreadRadius: _isPressed ? 2 : 0,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                // Shimmer overlay on press
                AnimatedBuilder(
                  animation: _shimmerAnimation,
                  builder: (context, _) {
                    return Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            stops: [
                              _shimmerAnimation.value - 0.3,
                              _shimmerAnimation.value,
                              _shimmerAnimation.value + 0.3,
                            ].map((s) => s.clamp(0.0, 1.0)).toList(),
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.12),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon with subtle background
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                        ),
                        child: Icon(
                          widget.icon,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.label,
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
