import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';

class NumberInputWidget extends StatelessWidget {
  const NumberInputWidget({
    super.key,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    this.suffix,
    this.isDouble = false,
  });

  final num value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final String? suffix;
  final bool isDouble;

  String get _display {
    if (isDouble) {
      return '${FormatUtils.weight(value.toDouble())}${suffix != null ? ' $suffix' : ''}';
    }
    return '${value.toInt()}${suffix != null ? ' $suffix' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Btn(icon: Icons.remove, onTap: onDecrement),
          Expanded(
            child: Text(
              _display,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.ink900,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          _Btn(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22,
        height: 22,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 12, color: AppColors.ink500),
      ),
    );
  }
}
