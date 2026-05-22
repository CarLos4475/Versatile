import 'package:flutter/material.dart';

import '../../../core/theme/accent_colors.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/motion.dart';

class AccentSwatchRail extends StatelessWidget {
  final AccentOption selected;
  final ValueChanged<AccentOption> onChanged;

  const AccentSwatchRail({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AccentColors.options.length,
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final opt = AccentColors.options[i];
          final active = opt.id == selected.id;
          return _Swatch(
            option: opt,
            active: active,
            name: opt.displayName(l10n),
            onTap: () => onChanged(opt),
          );
        },
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final AccentOption option;
  final bool active;
  final String name;
  final VoidCallback onTap;

  const _Swatch({
    required this.option,
    required this.active,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PressableScale(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: active
                  ? Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        border: Border.all(color: option.color, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Container(width: 32, height: 32, color: option.color),
                    )
                  : Container(width: 32, height: 32, color: option.color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.18,
              height: 1.0,
              color: active ? colors.accentDeep : colors.ink500,
            ),
          ),
        ],
      ),
    );
  }
}
