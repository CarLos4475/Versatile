import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class RecapPageDots extends StatelessWidget {
  const RecapPageDots({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (i) {
        final active = i == currentPage;
        final past = i < currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 26 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active
                ? colors.accentDeep
                : past
                    ? colors.accent.withValues(alpha: 0.55)
                    : colors.ink300,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
