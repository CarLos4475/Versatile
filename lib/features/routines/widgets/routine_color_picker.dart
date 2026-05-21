import 'package:flutter/material.dart';

import '../../../shared/widgets/motion.dart';

/// Brutalist color swatches: square blocks, active state shows a 3px inset
/// white border and a check mark. No radius, no shadows.
class RoutineColorPicker extends StatelessWidget {
  const RoutineColorPicker({
    super.key,
    required this.colors,
    required this.selectedColorValue,
    required this.onSelected,
  });

  final List<Color> colors;
  final int selectedColorValue;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: colors.map((color) {
        final active = color.toARGB32() == selectedColorValue;
        return PressableScale(
          onTap: () => onSelected(color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color,
              border: active
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
            ),
            child: active
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
