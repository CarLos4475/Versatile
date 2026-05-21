import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/motion.dart';

/// Brutalist icon picker: flat square tiles, active state uses solid accent.
class RoutineIconPicker extends StatelessWidget {
  const RoutineIconPicker({
    super.key,
    required this.icons,
    required this.selectedCode,
    required this.onSelected,
  });

  final List<IconData> icons;
  final int selectedCode;
  final ValueChanged<IconData> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: icons.map((icon) {
        final active = icon.codePoint == selectedCode;
        return PressableScale(
          onTap: () => onSelected(icon),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: active
                  ? colors.accent
                  : colors.ink900.withValues(alpha: 0.04),
              border: Border.all(
                color: active
                    ? colors.accentDeep.withValues(alpha: 0.6)
                    : colors.hairline,
                width: 0.6,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: active ? Colors.white : colors.ink700,
            ),
          ),
        );
      }).toList(),
    );
  }
}
