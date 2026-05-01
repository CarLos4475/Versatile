import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum GlassButtonVariant { primary, glass, ghost }
enum GlassButtonSize { sm, md, lg }

class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.label,
    this.variant = GlassButtonVariant.primary,
    this.size = GlassButtonSize.md,
    this.onPressed,
    this.leading,
    this.expand = false,
    this.loading = false,
  });

  final String label;
  final GlassButtonVariant variant;
  final GlassButtonSize size;
  final VoidCallback? onPressed;
  final Widget? leading;
  final bool expand;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final (h, px, fs, gap, r) = switch (size) {
      GlassButtonSize.sm => (36.0, 14.0, 13.0, 6.0, 12.0),
      GlassButtonSize.md => (48.0, 18.0, 15.0, 8.0, 16.0),
      GlassButtonSize.lg => (56.0, 22.0, 16.0, 10.0, 20.0),
    };

    final effectiveLeading = loading
        ? SizedBox(
            width: fs,
            height: fs,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: variant == GlassButtonVariant.primary
                  ? Colors.white
                  : AppColors.accentDeep,
            ),
          )
        : leading;

    return SizedBox(
      height: h,
      width: expand ? double.infinity : null,
      child: switch (variant) {
        GlassButtonVariant.primary => _PrimaryButton(
            px: px, fs: fs, gap: gap, r: r,
            label: label, leading: effectiveLeading, onPressed: onPressed,
          ),
        GlassButtonVariant.glass => _GlassVariantButton(
            px: px, fs: fs, gap: gap, r: r,
            label: label, leading: effectiveLeading, onPressed: onPressed,
          ),
        GlassButtonVariant.ghost => _GhostButton(
            px: px, fs: fs, gap: gap, r: r,
            label: label, leading: effectiveLeading, onPressed: onPressed,
          ),
      },
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.px, required this.fs, required this.gap, required this.r,
    required this.label, this.leading, this.onPressed,
  });
  final double px, fs, gap, r;
  final String label;
  final Widget? leading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: px),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE08866), Color(0xFFD97757), Color(0xFFC76346)],
            stops: [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(r),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentDeep.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, SizedBox(width: gap)],
            Text(label, style: TextStyle(
              color: Colors.white,
              fontSize: fs,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.01,
            )),
          ],
        ),
      ),
    );
  }
}

class _GlassVariantButton extends StatelessWidget {
  const _GlassVariantButton({
    required this.px, required this.fs, required this.gap, required this.r,
    required this.label, this.leading, this.onPressed,
  });
  final double px, fs, gap, r;
  final String label;
  final Widget? leading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: px),
            decoration: BoxDecoration(
              color: const Color(0x8DFFFCF7),
              borderRadius: BorderRadius.circular(r),
              border: Border.all(color: AppColors.glassBorder, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3C2814).withOpacity(0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[leading!, SizedBox(width: gap)],
                Text(label, style: TextStyle(
                  color: AppColors.ink900,
                  fontSize: fs,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.01,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.px, required this.fs, required this.gap, required this.r,
    required this.label, this.leading, this.onPressed,
  });
  final double px, fs, gap, r;
  final String label;
  final Widget? leading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: px),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, SizedBox(width: gap)],
            Text(label, style: TextStyle(
              color: AppColors.ink700,
              fontSize: fs,
              fontWeight: FontWeight.w600,
            )),
          ],
        ),
      ),
    );
  }
}

class IconCircleButton extends StatelessWidget {
  const IconCircleButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 38.0,
    this.radius = 12.0,
    this.accent = false,
    this.subtle = false,
  });

  final Widget icon;
  final VoidCallback onPressed;
  final double size;
  final double radius;
  final bool accent;
  final bool subtle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: accent
              ? const LinearGradient(
                  colors: [Color(0xFFE08866), Color(0xFFD97757)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          color: accent ? null : subtle
              ? const Color(0x0A000000)
              : const Color(0xA6FFFCF7),
          borderRadius: BorderRadius.circular(radius),
          border: accent || subtle ? null : Border.all(
            color: AppColors.glassBorder,
            width: 0.5,
          ),
          boxShadow: accent ? [
            BoxShadow(
              color: AppColors.accentDeep.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : subtle ? null : [
            BoxShadow(
              color: const Color(0xFF3C2814).withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: IconTheme(
            data: IconThemeData(
              color: accent ? Colors.white : AppColors.ink700,
              size: size * 0.52,
            ),
            child: icon,
          ),
        ),
      ),
    );
  }
}
