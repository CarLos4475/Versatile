import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/motion.dart';

class SoundChipGrid extends StatelessWidget {
  final String selected; // 'default' or 'custom'
  final ValueChanged<String> onChanged;
  final String defaultLabel;
  final String customLabel;
  final String? customFileName;

  const SoundChipGrid({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.defaultLabel,
    required this.customLabel,
    this.customFileName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.hairline, width: 0.5),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _SoundChip(
                label: defaultLabel,
                active: selected == 'default',
                onTap: () => onChanged('default'),
              ),
            ),
            Container(width: 0.5, color: colors.hairline),
            Expanded(
              child: _SoundChip(
                label: customLabel,
                sublabel: customFileName,
                active: selected == 'custom',
                onTap: () => onChanged('custom'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoundChip extends StatelessWidget {
  final String label;
  final String? sublabel;
  final bool active;
  final VoidCallback onTap;

  const _SoundChip({
    required this.label,
    this.sublabel,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        color: active ? colors.accent : Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: active
                      ? Colors.white
                      : colors.ink400.withValues(alpha: 0.7),
                  width: 1.4,
                ),
              ),
              child: active
                  ? Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.18,
                      color: active ? Colors.white : colors.ink500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (sublabel != null && sublabel!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      sublabel!,
                      style: TextStyle(
                        fontSize: 11,
                        color: active
                            ? Colors.white.withValues(alpha: 0.85)
                            : colors.ink400,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
