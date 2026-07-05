import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:ui';
import '../theme/app_colors.dart';

// ═══════════════════════════════════════════════════
//  GRADIENT BUTTON
// ═══════════════════════════════════════════════════

class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradient = AppColors.primaryGradient,
    this.height = 56.0,
    this.width = double.infinity,
    this.borderRadius = 16.0,
    this.textSize = 16.0,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
  });

  final String text;
  final VoidCallback onPressed;
  final LinearGradient gradient;
  final double height;
  final double? width;
  final double borderRadius;
  final double textSize;
  final IconData? icon;
  final bool isLoading;
  final bool enabled;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (widget.enabled && !widget.isLoading) {
          HapticFeedback.lightImpact();
          widget.onPressed();
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          opacity: widget.enabled ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: widget.enabled ? widget.gradient : null,
              color: widget.enabled ? null : AppColors.divider,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: widget.enabled
                  ? [
                      BoxShadow(
                        color: AppColors.primaryDark.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: widget.isLoading
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: GoogleFonts.tajawal(
                          fontSize: widget.textSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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

// ═══════════════════════════════════════════════════
//  CUSTOM TEXT FIELD
// ═══════════════════════════════════════════════════

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hint;
  final String? label;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          textInputAction: widget.textInputAction,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.tajawal(
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: GoogleFonts.tajawal(
              color: AppColors.textHint,
              fontSize: 14,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: AppColors.textHint, size: 20)
                : null,
            suffixIcon: widget.isPassword
                ? GestureDetector(
                    onTap: () => setState(() => _obscureText = !_obscureText),
                    child: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textHint,
                      size: 20,
                    ),
                  )
                : widget.suffixIcon,
            filled: true,
            fillColor: AppColors.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            counterStyle: GoogleFonts.tajawal(
              color: AppColors.textHint,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════
//  GLASS CARD
// ═══════════════════════════════════════════════════

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20.0,
    this.opacity = 0.08,
    this.borderOpacity = 0.15,
    this.blurColor,
    this.blur = 12.0,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double opacity;
  final double borderOpacity;
  final Color? blurColor;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: (blurColor ?? Colors.white).withOpacity(opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withOpacity(borderOpacity),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  GRADIENT CARD
// ═══════════════════════════════════════════════════

class GradientCard extends StatelessWidget {
  const GradientCard({
    super.key,
    required this.child,
    this.gradient = AppColors.cardGradient,
    this.padding,
    this.margin,
    this.borderRadius = 20.0,
    this.shadow = true,
  });

  final Widget child;
  final LinearGradient gradient;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

// ═══════════════════════════════════════════════════
//  LOADING WIDGET
// ═══════════════════════════════════════════════════

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    this.message,
    this.size = 40.0,
  });

  final String? message;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: GoogleFonts.tajawal(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  SECTION HEADER
// ═══════════════════════════════════════════════════

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.actionText,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? action;
  final String? actionText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.tajawal(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        if (action != null && actionText != null)
          TextButton(
            onPressed: action,
            child: Text(
              actionText!,
              style: GoogleFonts.tajawal(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════
//  ANIMATED HEART
// ═══════════════════════════════════════════════════

class AnimatedHeart extends StatelessWidget {
  const AnimatedHeart({
    super.key,
    this.size = 80.0,
    this.color = AppColors.secondary,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.favorite_rounded, size: size, color: color)
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.15, 1.15),
          duration: const Duration(milliseconds: 800),
        );
  }
}

// ═══════════════════════════════════════════════════
//  EMPTY STATE WIDGET
// ═══════════════════════════════════════════════════

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.actionText,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? action;
  final String? actionText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.textHint)
                .animate()
                .scale()
                .fadeIn(),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.tajawal(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitle!,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
            ],
            if (action != null && actionText != null) ...[
              const SizedBox(height: 32),
              GradientButton(
                text: actionText!,
                onPressed: action!,
                width: 200,
                height: 48,
              ).animate().fadeIn(delay: const Duration(milliseconds: 400)),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  CUSTOM APP BAR
// ═══════════════════════════════════════════════════

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBack = true,
    this.centerTitle = true,
    this.backgroundColor = Colors.transparent,
    this.elevation = 0,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBack;
  final bool centerTitle;
  final Color backgroundColor;
  final double elevation;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.tajawal(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      backgroundColor: backgroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      actions: actions,
      leading: leading ??
          (showBack && Navigator.of(context).canPop()
              ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null),
    );
  }
}

// ═══════════════════════════════════════════════════
//  DOTS INDICATOR
// ═══════════════════════════════════════════════════

class DotsIndicator extends StatelessWidget {
  const DotsIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    this.activeColor = AppColors.primary,
    this.inactiveColor = AppColors.divider,
  });

  final int count;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == currentIndex ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == currentIndex ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  SHIMMER LOADING
// ═══════════════════════════════════════════════════

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 1500),
          color: AppColors.cardLight,
        );
  }
}

// ═══════════════════════════════════════════════════
//  SMART IMAGE (Base64 & Network Support)
// ═══════════════════════════════════════════════════

class SmartImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SmartImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('base64:')) {
      final base64String = imageUrl.substring(7);
      return Image.memory(
        base64Decode(base64String),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
      );
    } else {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
      );
    }
  }

  Widget _buildErrorIcon() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[800],
      child: const Icon(Icons.broken_image_rounded, color: Colors.white54),
    );
  }
}

ImageProvider getSmartImageProvider(String imageUrl) {
  if (imageUrl.startsWith('base64:')) {
    return MemoryImage(base64Decode(imageUrl.substring(7)));
  } else {
    return NetworkImage(imageUrl);
  }
}

