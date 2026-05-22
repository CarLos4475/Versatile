import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/motion.dart';

class ThemeModePicker extends StatelessWidget {
  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;
  final String labelLight;
  final String labelDark;
  final String labelSystem;

  const ThemeModePicker({
    super.key,
    required this.value,
    required this.onChanged,
    required this.labelLight,
    required this.labelDark,
    required this.labelSystem,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ThemeCard(
            active: value == ThemeMode.light,
            icon: Icons.light_mode_outlined,
            label: labelLight,
            preview: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF5F0E6), Color(0xFFE4DCCB)],
            ),
            onTap: () => onChanged(ThemeMode.light),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ThemeCard(
            active: value == ThemeMode.dark,
            icon: Icons.dark_mode_outlined,
            label: labelDark,
            preview: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1F1A14), Color(0xFF14110D)],
            ),
            onTap: () => onChanged(ThemeMode.dark),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ThemeCard(
            active: value == ThemeMode.system,
            icon: Icons.brightness_auto_outlined,
            label: labelSystem,
            preview: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF5F0E6), Color(0xFF14110D)],
              stops: [0.5, 0.5],
            ),
            onTap: () => onChanged(ThemeMode.system),
          ),
        ),
      ],
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final bool active;
  final IconData icon;
  final String label;
  final LinearGradient preview;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.active,
    required this.icon,
    required this.label,
    required this.preview,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: active ? colors.accent : Colors.transparent,
          border: Border.all(
            color: active ? colors.accent : colors.hairline,
            width: active ? 1.0 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 2.4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: preview,
                  border: Border.all(
                    color: active
                        ? Colors.white.withValues(alpha: 0.4)
                        : colors.hairline.withValues(alpha: 0.6),
                    width: 0.5,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        width: 14,
                        height: 3,
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                    Positioned(
                      top: 11,
                      left: 4,
                      child: Container(
                        width: 24,
                        height: 2,
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 13,
                  color: active ? Colors.white : colors.ink500,
                ),
                const SizedBox(width: 5),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.18,
                    color: active ? Colors.white : colors.ink500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
