import 'package:flutter/material.dart';

import '../../../shared/widgets/motion.dart';

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
      spacing: 12,
      runSpacing: 12,
      children: colors.map((color) {
        final active = color.toARGB32() == selectedColorValue;
        return PressableScale(
          onTap: () => onSelected(color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: active ? Border.all(color: Colors.white, width: 3) : null,
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: active
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
