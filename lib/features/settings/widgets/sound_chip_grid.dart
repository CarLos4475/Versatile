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
    return Row(
      children: [
        Expanded(
          child: _SoundChip(
            label: defaultLabel,
            active: selected == 'default',
            onTap: () => onChanged('default'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SoundChip(
            label: customLabel,
            sublabel: customFileName,
            active: selected == 'custom',
            onTap: () => onChanged('custom'),
          ),
        ),
      ],
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: active
              ? colors.accentTint
              : colors.ink900.withValues(alpha: 0.04),
          border: Border.all(
            color: active
                ? colors.accent.withValues(alpha: 0.55)
                : colors.hairline.withValues(alpha: 0.45),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: active ? colors.accentDeep : colors.ink400,
                  width: 1.5,
                ),
              ),
              child: active
                  ? Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.accentDeep,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: active ? colors.accentDeep : colors.ink700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (sublabel != null && sublabel!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      sublabel!,
                      style: TextStyle(fontSize: 10, color: colors.ink500),
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
